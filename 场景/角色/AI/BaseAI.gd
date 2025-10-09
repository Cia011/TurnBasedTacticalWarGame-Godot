extends Node
class_name BaseAI

var unit: Unit
#@onready var action_manager: ActionsManager = unit.action_manager
var action_manager: ActionsManager
var test_grid_position:Vector2i
# 决策信号
signal decision_made(action: BaseAction, target_position: Vector2i)
signal turn_completed()
func _init(unit:Unit) -> void:
	self.unit = unit
	action_manager = unit.action_manager
# 主决策函数
func take_turn() -> void:
	print(unit.unit_data.character_name + " 开始思考...")
	# 评估所有可能的行动
	while (unit.current_action_points>0):
		test_grid_position = unit.grid_position
		#等一下bug
		#await get_tree().create_timer(0.1).timeout
		
		print(unit.current_action_points)
		var best_decision = evaluate_actions()
		if best_decision.action and best_decision.target_position != Vector2i(-1, -1):
			
			#print(unit.current_action_points)
			print("选择行动: ", best_decision.action.action_name, " 目标: ", best_decision.target_position)
			decision_made.emit(best_decision.action, best_decision.target_position)
			# 执行行动
			await execute_action(best_decision.action, best_decision.target_position)
			
		else:
			print("没有有效行动，跳过回合")
			skip_turn()

# 执行行动
func execute_action(action: BaseAction, target_position: Vector2i) -> void:

	BattleGridManager.visulize_grids(action.get_action_grids() ,action.grid_color)
	BattleActionManager.perform_action(action,target_position)
	await action.action_finished

#func _on_action_finished():
	#turn_completed.emit()

func skip_turn() -> void:
	print(unit.unit_data.character_name + " 跳过回合")
	BattleTurnManager.set_next_turn_unit()
	turn_completed.emit()

# 需要子类实现的具体评估逻辑
func evaluate_actions() -> Dictionary:
	return {"action": null, "target_position": Vector2i(-1, -1)}
