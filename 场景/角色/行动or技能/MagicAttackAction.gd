extends BaseAction
class_name MagicAttackAction

# 魔法攻击属性
var max_range = 10  # 魔法攻击范围比普通攻击更远
var damage = 15    # 魔法伤害

# 火球场景 - 需要您创建一个火球场景
const FIREBALL_SCENE = preload("res://场景/角色/行动or技能/效果/fireball.tscn")

func _ready() -> void:
	super._ready()
	is_need_target = true
	is_instant = false
	cost = 2
func start_action(target_grid_position: Vector2i, on_action_finished: Callable):
	super.start_action(target_grid_position, on_action_finished)
	# 检查目标是否有效
	if not is_valid_action_grid(target_grid_position):
		finish_action()
		return
	if unit.get_action_points()<cost:
		PopManager.pop_lable(unit.position,str("行动力不足"),Color.DARK_ORANGE)
		finish_action()
		return
	
	# 播放施法动画
	var animation_player = $"../../AnimationPlayer" as AnimationPlayer
	animation_player.play("attack")
	var finished_animation_name = await animation_player.animation_finished
	
	if finished_animation_name == "attack":
		animation_player.play("RESET")
		# 创建并发射火球
		await launch_fireball(target_grid_position)
		
		# 火球命中后处理伤害
		var target_unit: Unit = BattleGridManager.get_grid_occupied(target_grid_position)
		attack_logic(target_unit)
		finish_animation()
	else:
		finish_action()

func is_valid_action_grid(target_grid_position: Vector2i) -> bool:
	# 检查目标位置是否有单位且距离在范围内
	if not BattleGridManager.is_grid_occupied(target_grid_position):
		return false
	
	## 计算与目标的距离
	#var distance = unit.grid_position.distance_to(target_grid_position)
	#if distance > max_range:
		#return false
	
	return true

func launch_fireball(target_grid_position: Vector2i):
	# 创建火球实例
	var fireball = FIREBALL_SCENE.instantiate()
	#get_tree().current_scene.add_child(fireball)
	PopManager.special_effects_node.add_child(fireball)
	# 设置火球起始位置（施法者位置）
	var start_pos = BattleGridManager.get_world_position(unit.grid_position)
	start_pos.y -= 20  # 稍微抬高一点，从角色手部发射
	
	# 设置火球目标位置
	var target_pos = BattleGridManager.get_world_position(target_grid_position)
	target_pos.y -= 10  # 稍微抬高一点，击中目标上半身
	
	# 初始化火球
	if fireball.has_method("initialize"):
		fireball.initialize(start_pos, target_pos)
	
	# 等待火球到达目标
	await fireball.arrived_at_target
	
	# 移除火球
	fireball.queue_free()

func attack_logic(target_unit: Unit):
	# 魔法攻击逻辑 - 对目标造成魔法伤害
	target_unit.data_manager.remove_final_bonus("current_health", damage)
	print("火球对 ", target_unit.unit_data.character_name, " 造成了 ", damage, " 点伤害!")
	
	# 魔法攻击可能有一些特殊效果，比如点燃状态
	# 这里可以添加额外的状态效果
	# apply_burn_effect(target_unit)

# 可选：添加点燃效果
func apply_burn_effect(target_unit: Unit):
	# 如果有燃烧Buff系统，可以在这里应用
	# 例如：target_unit.buff_manager.add_burn_buff(3, 2) # 持续3回合，每回合2点伤害
	pass

func finish_animation():
	var current_action_points = unit.get_action_points() - cost
	unit.set_action_points(current_action_points)
	finish_action()

func get_action_grids(unit_grid: Vector2i = unit.grid_position) -> Array[Vector2i]:
	var results:Array[Vector2i] = []
	results = BattleGridManager.D_get_all_path(unit_grid,max_range)["reachable"]
	return results

# 获取魔法攻击的显示范围（用于UI显示）
func get_display_range() -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var unit_grid = unit.grid_position
	
	# 获取所有在范围内的格子（包括空的和被占据的）
	for x in range(-max_range, max_range + 1):
		for y in range(-max_range, max_range + 1):
			var grid_pos = unit_grid + Vector2i(x, y)
			var distance = unit_grid.distance_to(grid_pos)
			
			if distance <= max_range:
				results.append(grid_pos)
	return results
