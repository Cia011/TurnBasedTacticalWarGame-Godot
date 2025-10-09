extends Node
class_name BaseAI

var unit: Unit
#@onready var action_manager: ActionsManager = unit.action_manager
var action_manager: ActionsManager
var test_grid_position:Vector2i
# 决策信号
signal decision_made(action: BaseAction, target_position: Vector2i)
signal turn_completed()
# 创建一个工作线程
var _think_thread: Thread
# 创建信号，用于通知决策完成
signal decision_ready(action: BaseAction, target_position: Vector2i)
# 在适当的时候销毁线程，避免内存泄漏
func _exit_tree():
	if _think_thread and _think_thread.is_started():
		_think_thread.wait_to_finish()
# 这个函数将在工作线程中运行
func _threaded_evaluate_actions() -> void:
	# 这里是你的AI决策逻辑，可能会比较耗时
	var best_decision = evaluate_actions()
	# 决策完成后，使用 call_deferred 安全地发出信号
	call_deferred("emit_signal", "decision_ready", best_decision.action, best_decision.target_position)

func _init(unit:Unit) -> void:
	self.unit = unit
	action_manager = unit.action_manager
func _ready():
	# 连接决策完成信号
	decision_ready.connect(_on_decision_ready)
func _on_decision_ready(action: BaseAction, target_position: Vector2i):
	print("异步思考完成，行动: ", action.action_name, " 目标: ", target_position)
	decision_made.emit(action, target_position)
	# 执行行动，这里假设 execute_action 内部会处理行动力消耗并等待行动完成
	execute_action(action, target_position)
	# 注意：你可能需要在这里等待行动执行完毕，再发出 turn_completed
	# 这取决于你的 execute_action 实现，如果它是异步的，你可能需要 await

	# 假设 execute_action 内部会处理好行动力和行动动画，并在最终完成时调用一个回调或发出信号
	# 例如，你可以在 execute_action 最后 await action.action_finished (如果它有这个信号)
	# 然后才 turn_completed.emit()
# 主决策函数
func take_turn() -> void:
	#print(unit.unit_data.character_name + " 开始思考...")
	print(unit.unit_data.character_name + " 开始异步思考...")
	_think_thread = Thread.new()
	var error = _think_thread.start(_threaded_evaluate_actions)
	if error != OK:
		push_error("无法启动AI思考线程!")
		# 如果线程启动失败，可以回退到主线程决策（可能会卡）
		var fallback_decision = evaluate_actions()
	# 评估所有可能的行动
	var i = 1
	while (unit.current_action_points>0):
		print("执行次数"+str(i))
		i+=1
	
		test_grid_position = unit.grid_position
		
		
		print(unit.current_action_points)
		var best_decision = evaluate_actions()
		if best_decision.action and best_decision.target_position != Vector2i(-1, -1):
			#print(unit.current_action_points)
			print("选择行动: ", best_decision.action.action_name, " 目标: ", best_decision.target_position)
			decision_made.emit(best_decision.action, best_decision.target_position)
			# 执行行动
			await execute_action(best_decision.action, best_decision.target_position)
			#等一下bug
			#await get_tree().create_timer(1).timeout
			
		else:
			print("没有有效行动，跳过回合")
			skip_turn()
			break
	skip_turn()
# 执行行动
func execute_action(action: BaseAction, target_position: Vector2i) -> void:

	BattleGridManager.visulize_grids(action.get_action_grids() ,action.grid_color)
	BattleActionManager.perform_action(action,target_position)
	await action.action_finished
	print("执行完成")
#func _on_action_finished():
	#turn_completed.emit()

func skip_turn() -> void:
	print(unit.unit_data.character_name + " 跳过回合")
	BattleTurnManager.set_next_turn_unit()
	turn_completed.emit()

# 需要子类实现的具体评估逻辑
func evaluate_actions() -> Dictionary:
	return {"action": null, "target_position": Vector2i(-1, -1)}
