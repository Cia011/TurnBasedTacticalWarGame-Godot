extends Node2D
class_name Unit


@onready var action_manager: ActionsManager = $ActionsManager
@onready var health_ui: Node = $HealthUI
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

@onready var body: Sprite2D = $图像/body
@export var bodytexture : Texture2D

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

## 把所有精灵图按层级叠加成一张最终图片
func get_combined_image() -> Image:
	var bounds := Rect2()
	var prepared: Array[Dictionary] = []
	var body_node := get_node_or_null("图像/body") as Sprite2D
	if body_node and body_node.texture and body_node.visible:
		var body_entry := _prepare_image_entry(body_node.texture, body_node.position, body_node.scale, body_node.offset)
		if not body_entry.is_empty():
			prepared.append(body_entry)
	var sorted_overlays := _overlay_data.duplicate()
	sorted_overlays.sort_custom(_compare_overlay_layer)
	for overlay in sorted_overlays:
		if overlay == null or overlay.texture == null or not overlay.visible:
			continue
		var entry := _prepare_image_entry(overlay.texture, overlay.position, overlay.scale, overlay.offset)
		if not entry.is_empty():
			prepared.append(entry)

	var first_entry := true
	for entry in prepared:
		var part_rect: Rect2 = entry["rect"]
		if first_entry:
			bounds = part_rect
			first_entry = false
		else:
			bounds = bounds.merge(part_rect)

	if prepared.is_empty():
		return Image.create(1, 1, false, Image.FORMAT_RGBA8)

	var canvas := Image.create(
		maxi(1, ceili(bounds.size.x)),
		maxi(1, ceili(bounds.size.y)),
		false,
		Image.FORMAT_RGBA8
	)
	canvas.fill(Color(0, 0, 0, 0))
	for entry in prepared:
		var src: Image = entry["image"]
		var dst := Vector2i((entry["rect"].position - bounds.position).floor())
		canvas.blit_rect(src, Rect2i(0, 0, src.get_width(), src.get_height()), dst)
	return canvas


func _compare_overlay_layer(a: CharacterOverlayData, b: CharacterOverlayData) -> bool:
	return a.layer < b.layer


func _prepare_image_entry(texture: Texture2D, position: Vector2, scale: Vector2, offset: Vector2) -> Dictionary:
	var src := texture.get_image()
	if src == null:
		return {}
	var final_scale := scale
	if final_scale.x < 0.0:
		src = src.duplicate()
		src.flip_x()
		final_scale.x = -final_scale.x
	if final_scale.y < 0.0:
		src = src.duplicate()
		src.flip_y()
		final_scale.y = -final_scale.y
	if final_scale != Vector2.ONE:
		src = src.duplicate()
		src.resize(
			maxi(1, roundi(src.get_width() * final_scale.x)),
			maxi(1, roundi(src.get_height() * final_scale.y)),
			Image.INTERPOLATE_NEAREST
		)
	var top_left := position + offset - Vector2(src.get_width(), src.get_height()) * 0.5
	return {"image": src, "rect": Rect2(top_left, Vector2(src.get_width(), src.get_height()))}


## 把变装后的最终图片保存为 PNG
func save_combined_png(path: String) -> bool:
	var image := get_combined_image()
	return image.save_png(path) == OK

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
	var body_node := get_node_or_null("图像/body") as Sprite2D
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
			PopManager.pop_lable(self.position,str(new_stats["current_health"]-pre_health),Color.RED)
		elif(change_health>0):
			PopManager.pop_lable(self.position,"+"+str(new_stats["current_health"]-pre_health),Color.GREEN)
		
		health_ui.set_up(get_stat("max_health"),get_stat("current_health"))
		
		#死亡逻辑
		if get_stat("current_health")<=0:
			unit_die.emit(self)
		pre_health = new_stats["current_health"]
