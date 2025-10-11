extends BaseAction
class_name AttackAction

var max_length = 1
var damage = 20   # 魔法伤害
func _ready() -> void:
	super._ready()
	cost = 2
	is_need_target = true
	is_instant = false

func start_action(target_grid_position:Vector2i,on_action_finished:Callable):
	super.start_action(target_grid_position,on_action_finished)
	if unit.get_action_points()<cost:
		PopManager.pop_lable(unit.position,str("行动力不足"),Color.DARK_ORANGE)
		finish_action()
		return
	#攻击必须有目标
	if is_valid_action_grid(target_grid_position):
		var target_unit:Unit = BattleGridManager.get_grid_occupied(target_grid_position)
		var animation_player = $"../../AnimationPlayer" as AnimationPlayer
		animation_player.play("attack")
		var finished_animation_name = await animation_player.animation_finished
		if finished_animation_name == "attack":
			animation_player.play("RESET")
			attack_logic(target_unit)
			finish_animation()
	else:
		PopManager.pop_lable(unit.position,str("目标不合法"),Color.DARK_ORANGE)
		finish_action()
	#未实现攻击动画,直接结束行动
	
func is_valid_action_grid(target_grid_position:Vector2i)->bool:
	return BattleGridManager.is_grid_occupied(target_grid_position)
func attack_logic(target_unit:Unit):
	#具体攻击逻辑
	target_unit.data_manager.remove_final_bonus("current_health",20)
	#print(target_unit.data_manager.get_stat("current_health"))
	#unit.data_manager.remove_final_bonus("current_health",-20)
func finish_animation():
	var current_action_points = unit.get_action_points() - cost
	unit.set_action_points(current_action_points)
	finish_action()

func get_action_grids(unit_grid:Vector2i = unit.grid_position)->Array[Vector2i]:
	var results:Array[Vector2i] = []
	results = BattleGridManager.D_get_all_path(unit_grid,max_length)["reachable"]
	return results
