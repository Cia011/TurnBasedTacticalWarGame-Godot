extends BaseAction
class_name TurnEndAction

func _ready() -> void:
	super._ready()
	is_need_target = false
	is_instant = true
func start_action(target_grid_position:Vector2i,on_action_finished:Callable):
	super.start_action(target_grid_position,on_action_finished)
	print("结束回合")
	BattleTurnManager.set_next_turn_unit()
	
	finish_action()
