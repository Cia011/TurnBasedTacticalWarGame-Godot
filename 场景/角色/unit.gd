extends Node2D
class_name Unit


@onready var action_manager: ActionsManager = $ActionsManager
@onready var health_ui: Node = $HealthUI
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#--------------shader---------------------
var shader_material: ShaderMaterial
#---------------------------------------
var data_manager: DataManager
var buff_manager: BuffManager

var is_teammate : bool = true
var pre_health:int
var current_action_points:int
var AI : BaseAI
signal unit_die(unit:Unit)
signal current_action_points_changed(new_value:int)
signal equipment_animation_finished(anim_name:String)

var grid_position:Vector2i
#var grid_position :Vector2i:
	#get:return BattleGridManager.get_grid_position(global_position)
func get_grid_position()->Vector2i:
	return grid_position

# ------- 变装系统：动态图像覆盖 -------
const EQUIPMENT_SLOT_KEYS: Array[String] = ["主手", "副手", "盔甲", "头盔", "戒指", "项链", "道具"]

## 图像覆盖数组：保存贴图、位置、缩放、偏移与层级
var _overlay_data: Array[CharacterOverlayData] = []
## overlay_id -> Sprite2D
var _overlay_nodes: Dictionary = {}
var _overlay_layer: Node2D
var _equipment_animation_clips: Dictionary = {}
var _animation_finished_callback: Callable


## 确保覆盖层存在，并保留一个供攻击动画使用的 weapon 占位节点
func _ensure_overlay_layer() -> void:
	if _overlay_layer != null and is_instance_valid(_overlay_layer):
		return
	var image_root := get_node_or_null("图像") as Node2D
	if image_root == null:
		return
	_overlay_layer = image_root.get_node_or_null("OverlayLayer") as Node2D
	if _overlay_layer == null:
		_overlay_layer = Node2D.new()
		_overlay_layer.name = "OverlayLayer"
		image_root.add_child(_overlay_layer)
	if _overlay_layer.get_node_or_null("weapon") == null:
		var placeholder := Sprite2D.new()
		placeholder.name = "weapon"
		_overlay_layer.add_child(placeholder)


func get_body_center() -> Vector2:
	var body_node := get_node_or_null("图像/body") as Sprite2D
	if body_node:
		return body_node.position + body_node.offset
	return Vector2.ZERO


## 根据 unit_data 的装备数据重建图像覆盖数组并动态创建 Sprite2D
func rebuild_equipment_overlays() -> void:
	clear_overlays()
	_ensure_overlay_layer()
	if unit_data == null:
		return
	var body_center := get_body_center()
	for slot_key in EQUIPMENT_SLOT_KEYS:
		var item := unit_data.get_equipped_item(slot_key)
		if item == null or item.appearance_image == null:
			continue
		var overlay := CharacterOverlayData.new()
		overlay.overlay_id = "%s_%s" % [slot_key, item.item_name]
		overlay.texture = item.appearance_image
		overlay.position = body_center + item.appearance_position
		overlay.scale = item.appearance_scale
		overlay.offset = item.appearance_offset
		overlay.layer = item.appearance_layer
		overlay.source_slot = slot_key
		add_overlay(overlay, slot_key == "主手")


## 兼容旧接口：刷新装备外观
func refresh_appearance_from_equipment() -> void:
	rebuild_equipment_overlays()


## 添加一个图像覆盖，返回 overlay_id；buff 等系统可通过它叠加脚下藤蔓等效果
func add_overlay(overlay: CharacterOverlayData, is_main_weapon: bool = false) -> String:
	if overlay == null or overlay.texture == null:
		return ""
	if overlay.overlay_id.is_empty():
		overlay.overlay_id = "overlay_%d" % _overlay_data.size()
	_overlay_data.append(overlay)
	var sprite := _create_overlay_sprite(overlay, is_main_weapon)
	if sprite == null:
		_overlay_data.pop_back()
		return ""
	return overlay.overlay_id


func remove_overlay(overlay_id: String) -> void:
	for i in range(_overlay_data.size() - 1, -1, -1):
		if _overlay_data[i].overlay_id == overlay_id:
			_overlay_data.remove_at(i)
			break
	var node := _overlay_nodes.get(overlay_id) as Sprite2D
	if node and is_instance_valid(node):
		if node.name == "weapon":
			_reset_weapon_placeholder(node)
		else:
			node.queue_free()
	_overlay_nodes.erase(overlay_id)


func clear_overlays() -> void:
	for node in _overlay_nodes.values():
		if node is Sprite2D and is_instance_valid(node):
			if node.name == "weapon":
				_reset_weapon_placeholder(node)
			else:
				node.queue_free()
	_overlay_nodes.clear()
	_overlay_data.clear()


func set_overlay_transform(overlay_id: String, position: Vector2, scale: Vector2 = Vector2.ONE, offset: Vector2 = Vector2.ZERO) -> void:
	var node := _overlay_nodes.get(overlay_id) as Sprite2D
	if node:
		node.position = position
		node.scale = scale
		node.offset = offset


func get_overlay_data() -> Array[CharacterOverlayData]:
	return _overlay_data.duplicate()


## 播放某件装备定义的动画（attack/hit 等），返回是否成功开始播放
func play_equipment_animation(anim_name: String, prefer_slot: String = "") -> bool:
	if unit_data == null or anim_name.is_empty():
		return false
	var result := _find_animation_sprite(anim_name, prefer_slot)
	if result.is_empty():
		return false
	var sprite: Sprite2D = result["sprite"]
	var item: BaseEquipmentItemData = result["item"]
	var anim: Dictionary = item.get_animation(anim_name)
	if anim.is_empty() or (anim.get("keys", []) as Array).is_empty():
		return false
	_play_equipment_animation_clip(sprite, anim, anim_name)
	return true


func stop_equipment_animation() -> void:
	if animation_player:
		animation_player.stop()
	_animation_finished_callback = Callable()


func _find_animation_sprite(anim_name: String, prefer_slot: String) -> Dictionary:
	var slot_order: Array[String] = []
	if not prefer_slot.is_empty():
		slot_order.append(prefer_slot)
	for slot_key in EQUIPMENT_SLOT_KEYS:
		if not slot_order.has(slot_key):
			slot_order.append(slot_key)
	for slot_key in slot_order:
		var item := unit_data.get_equipped_item(slot_key)
		if item == null or not item.has_animation(anim_name):
			continue
		var anim: Dictionary = item.get_animation(anim_name)
		var target := str(anim.get("target", ""))
		var sprite: Sprite2D = null
		if target == "body":
			sprite = get_node_or_null("图像/body") as Sprite2D
		else:
			var overlay_id := "%s_%s" % [slot_key, item.item_name]
			sprite = _overlay_nodes.get(overlay_id) as Sprite2D
			if sprite == null:
				sprite = get_node_or_null("图像/body") as Sprite2D
		if sprite:
			return {"sprite": sprite, "item": item, "slot": slot_key}
	return {}


func _play_equipment_animation_clip(sprite: Sprite2D, anim: Dictionary, anim_name: String) -> void:
	var clip_name := _get_or_build_equipment_clip(sprite, anim, anim_name)
	if clip_name.is_empty():
		return
	if _animation_finished_callback.is_valid() and animation_player.animation_finished.is_connected(_animation_finished_callback):
		animation_player.animation_finished.disconnect(_animation_finished_callback)
	_animation_finished_callback = _on_equipment_animation_finished.bind(clip_name)
	animation_player.animation_finished.connect(_animation_finished_callback, CONNECT_ONE_SHOT)
	animation_player.play(clip_name)


func _get_or_build_equipment_clip(sprite: Sprite2D, anim: Dictionary, anim_name: String) -> String:
	var cache_key := "%d_%s_%s" % [sprite.get_instance_id(), anim_name, str(anim.get("target", ""))]
	if _equipment_animation_clips.has(cache_key):
		return str(_equipment_animation_clips[cache_key])
	var clip_name := "equip_%s_%d" % [anim_name, sprite.get_instance_id()]
	var library := _get_animation_library()
	if library == null:
		return ""
	var clip := _build_animation_resource(sprite, anim)
	if clip == null:
		return ""
	library.add_animation(clip_name, clip)
	_equipment_animation_clips[cache_key] = clip_name
	return clip_name


func _get_animation_library() -> AnimationLibrary:
	var library := animation_player.get_animation_library(&"")
	if library == null:
		library = AnimationLibrary.new()
		animation_player.add_animation_library(&"", library)
	return library


func _build_animation_resource(sprite: Sprite2D, anim: Dictionary) -> Animation:
	var keys: Array = anim.get("keys", [])
	if keys.is_empty():
		return null
	var clip := Animation.new()
	clip.length = 0.0
	var base_position := sprite.position
	var base_scale := sprite.scale
	var base_rotation := sprite.rotation
	var current_position := base_position
	var current_scale := base_scale
	var current_rotation := base_rotation

	var track_position := clip.add_track(Animation.TYPE_VALUE)
	clip.track_set_path(track_position, _animation_track_path(sprite, "position"))
	var track_scale := clip.add_track(Animation.TYPE_VALUE)
	clip.track_set_path(track_scale, _animation_track_path(sprite, "scale"))
	var track_rotation := clip.add_track(Animation.TYPE_VALUE)
	clip.track_set_path(track_rotation, _animation_track_path(sprite, "rotation"))

	for key in keys:
		var time := float(key.get("time", 0.0))
		if key.has("position"):
			current_position = base_position + key["position"]
		if key.has("scale"):
			current_scale = key["scale"]
		if key.has("rotation"):
			current_rotation = deg_to_rad(float(key["rotation"]))
		clip.track_insert_key(track_position, time, current_position)
		clip.track_insert_key(track_scale, time, current_scale)
		clip.track_insert_key(track_rotation, time, current_rotation)
		clip.length = maxf(clip.length, time)

	var loop := bool(anim.get("loop", false))
	clip.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	if not loop and bool(anim.get("restore", true)):
		var restore_time := clip.length + 0.12
		clip.track_insert_key(track_position, restore_time, base_position)
		clip.track_insert_key(track_scale, restore_time, base_scale)
		clip.track_insert_key(track_rotation, restore_time, base_rotation)
		clip.length = restore_time
	return clip


func _animation_track_path(sprite: Sprite2D, property: String) -> NodePath:
	var root := animation_player.get_node_or_null(animation_player.root_node) as Node
	var relative := root.get_path_to(sprite) if root else animation_player.get_path_to(sprite)
	return NodePath("%s:%s" % [str(relative), property])


func _on_equipment_animation_finished(finished_name: StringName, expected_clip: String) -> void:
	if str(finished_name) != expected_clip:
		return
	equipment_animation_finished.emit(str(finished_name))
	_animation_finished_callback = Callable()


func _create_overlay_sprite(overlay: CharacterOverlayData, is_main_weapon: bool) -> Sprite2D:
	_ensure_overlay_layer()
	if _overlay_layer == null or overlay == null or overlay.texture == null:
		return null
	var sprite: Sprite2D
	if is_main_weapon:
		sprite = _overlay_layer.get_node_or_null("weapon") as Sprite2D
		if sprite == null:
			sprite = Sprite2D.new()
			sprite.name = "weapon"
			_overlay_layer.add_child(sprite)
	else:
		sprite = Sprite2D.new()
		sprite.name = _unique_overlay_name(overlay.overlay_id)
		_overlay_layer.add_child(sprite)
	sprite.texture = overlay.texture
	sprite.position = overlay.position
	sprite.scale = overlay.scale
	sprite.offset = overlay.offset
	sprite.z_index = overlay.layer
	sprite.visible = overlay.visible
	sprite.centered = true
	_overlay_nodes[overlay.overlay_id] = sprite
	return sprite


func _unique_overlay_name(base_name: String) -> String:
	if base_name.is_empty():
		base_name = "overlay"
	var candidate := base_name
	var suffix := 2
	while _overlay_layer.get_node_or_null(candidate) != null:
		candidate = "%s_%d" % [base_name, suffix]
		suffix += 1
	return candidate


func _reset_weapon_placeholder(node: Sprite2D) -> void:
	node.texture = null
	node.position = Vector2.ZERO
	node.scale = Vector2.ONE
	node.offset = Vector2.ZERO
	node.z_index = 0
	node.visible = true

## 把所有身体+装备图层叠加成一张最终图片（与大地图共用合成服务）
func get_combined_image() -> Image:
	var extra_overlays: Array[CharacterOverlayData] = []
	for overlay in _overlay_data:
		if overlay.source_slot.is_empty():
			extra_overlays.append(overlay)
	return CharacterPortraitService.get_combined_image(unit_data, extra_overlays)


## 把变装后的最终图片保存为 PNG
func save_combined_png(path: String) -> bool:
	var image := get_combined_image()
	return image.save_png(path) == OK
#--------------------------UnitData-----------------------------
var unit_data:UnitData
#从data_manager中获取属性
#单独写一个函数是为了方便使用 即 委托方法
func get_stat(stat_name:String):
	return unit_data.get_final_stat(stat_name)
func get_action_points()->int:
	return current_action_points
func set_action_points(num:int):
	current_action_points = num
	current_action_points_changed.emit(num)

#回合开始执行
func start_turn():
	current_action_points = unit_data.get_final_stat("action_points")
	
	shader_material.set_shader_parameter("show_line", true)
	if is_teammate == false:
		shader_material.set_shader_parameter("outline_color", Color.BROWN)
		start_enemy_turn()
func end_turn():
	shader_material.set_shader_parameter("show_line", false)

func start_enemy_turn():
	await AI.take_turn()
	#await AI.turn_completed
#再ready前执行
func set_up(unit_data:UnitData,grid_position:Vector2i):
	self.unit_data = unit_data
	name = self.unit_data.character_name
	set_grid_position(grid_position)

	data_manager = unit_data.data_manager
	buff_manager = unit_data.buff_manager
	data_manager.stat_changed.connect(unit_data_change)

func _ready() -> void:
	if not unit_data:
		print("[unit] [error]unit_data不存在")
		return
	if not buff_manager:
		print("[unit] [error]buff_manager不存在")
		return
	var body_node := get_node_or_null("图像/body") as Sprite2D
	if body_node:
		body_node.position = unit_data.body_position
		body_node.offset = unit_data.body_offset
		if unit_data.texture:
			body_node.texture = unit_data.texture
	rebuild_equipment_overlays()
	#角色创建时在BattleUnitManager内注册
	BattleUnitManager.register_unit(self)
	
	pre_health = get_stat("current_health")
	
	#角色创建时设置HealthUI#初始化
	#health_ui.set_up(unit_data.max_health,unit_data.current_health)
	health_ui.set_up(get_stat("max_health"),get_stat("current_health"),is_teammate)
	
	if is_teammate == false:
		AI = AggressiveEnemyAI.new(self)
		add_child(AI)
	#--------------shader---------------------
	shader_material = body_node.material as ShaderMaterial if body_node else null

#由角色生成器来控制生成角色的位置,目前角色生成器为战斗场景根节点
func set_grid_position(grid_position:Vector2i)->void:
	#设置位置
	position = BattleGridManager.get_world_position(grid_position)
	self.grid_position = grid_position
	
	#在相应位置网格注册自身
	BattleGridManager.set_grid_occupied(grid_position,self)
#当属性管理器发生改变时自动执行(因为连接了信号)
func unit_data_change(new_stats:Dictionary):
	if new_stats.has("current_health"):
		#受伤弹幕
		var change_health:int = new_stats["current_health"]-pre_health
		if(change_health<=0):
			play_equipment_animation("hit")
			PopManager.pop_lable(self.position,str(new_stats["current_health"]-pre_health),Color.RED)
		elif(change_health>0):
			PopManager.pop_lable(self.position,"+"+str(new_stats["current_health"]-pre_health),Color.GREEN)
		
		health_ui.set_up(get_stat("max_health"),get_stat("current_health"))
		
		#死亡逻辑
		if get_stat("current_health")<=0:
			unit_die.emit(self)
		pre_health = new_stats["current_health"]
