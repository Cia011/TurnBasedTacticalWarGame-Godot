extends Node
class_name BaseAI

var unit: Unit
#@onready var action_manager: ActionsManager = unit.action_manager
var action_manager: ActionsManager
var test_grid_position:Vector2i
# 决策信号
signal decision_made(action: BaseAction, target_position: Vector2i)
signal turn_completed()

# 异步思考相关
var _think_thread: Thread # 创建一个工作线程
var _current_decision: Dictionary
var _is_thinking: bool = false

func _init(unit:Unit) -> void:
	self.unit = unit
	action_manager = unit.action_manager

# 主决策函数
func take_turn() -> void:

	var action_count = 0
	var max_actions_per_turn = 5  # 防止无限循环的安全限制
	# 评估所有可能的行动
	
	while (unit.get_action_points()>0 and action_count < max_actions_per_turn):
		action_count += 1
		print("第 " + str(action_count) + " 次决策，剩余行动力: " + str(unit.current_action_points))
		test_grid_position = unit.get_grid_position()
		# 在主线程收集所有需要的数据
		#_update_snapshot_data()
		 # 异步评估行动
		var decision = await evaluate_actions_async()
		# 检查决策是否有效
		
		if not decision.action or decision.target_position == Vector2i(-1, -1):
			print("没有找到有效行动")
			break
		# 检查行动力是否足够
		if unit.current_action_points < decision.action.cost:
			print("行动力不足，无法执行: " + decision.action.action_name)
			break
		print("选择行动: " + decision.action.action_name + " 目标: " + str(decision.target_position))
		
		 # 执行行动并等待完成
		await execute_action(decision.action, decision.target_position)
	print(unit.unit_data.character_name + " 回合结束")
	turn_completed.emit()
	skip_turn()
#______________________________________________________________________
# 收集线程安全的数据快照

#______________________________________________________________________
# 异步评估行动
func evaluate_actions_async() -> Dictionary:
	# 如果已经在思考，等待之前的思考完成
	if _is_thinking:
		await get_tree().process_frame  # 让出一帧避免阻塞
	_is_thinking = true
	
	# 在线程中进行复杂的AI计算:cite[1]
	if _think_thread and _think_thread.is_started():
		_think_thread.wait_to_finish()
	
	_think_thread = Thread.new()
	_current_decision = {"action": null, "target_position": Vector2i(-1, -1)}
	
	#开始子线程
	var error = _think_thread.start(_threaded_evaluate_actions)
	
	if error != OK:
		push_error("无法启动AI思考线程!")
		_is_thinking = false
		# 回退到主线程评估
		return evaluate_actions_sync()
	
	# 等待线程完成，但不阻塞主线程:cite[8]
	await wait_for_thread_completion()
	
	_is_thinking = false
	return _current_decision
# 线程中执行的评估函数
func _threaded_evaluate_actions() -> void:
	# 这里执行耗时的AI决策逻辑
	var decision = evaluate_actions()
	# 使用 call_deferred 安全地更新主线程数据
	call_deferred("_set_current_decision", decision)

# 安全设置决策结果
func _set_current_decision(decision: Dictionary) -> void:
	_current_decision = decision
# 等待线程完成的协程:cite[8]
func wait_for_thread_completion() -> void:
	while _think_thread and _think_thread.is_alive():
		await get_tree().process_frame  # 每帧检查一次
# 同步评估（回退方案）
func evaluate_actions_sync() -> Dictionary:
	print("使用同步评估")
	return evaluate_actions()
# 执行行动
func execute_action(action: BaseAction, target_position: Vector2i) -> void:
	# 可视化行动范围:cite[4]
	BattleGridManager.visulize_grids(action.get_action_grids(), action.grid_color)
	
	# 执行行动并等待完成:cite[8]
	BattleActionManager.perform_action(action, target_position)
	await action.action_finished
	
	print("行动执行完成")

#func _on_action_finished():
	#turn_completed.emit()
func skip_turn() -> void:
	print(unit.unit_data.character_name + " 跳过回合")
	BattleTurnManager.set_next_turn_unit()
	turn_completed.emit()
# 清理资源:cite[1]
func _exit_tree():
	if _think_thread and _think_thread.is_started():
		_think_thread.wait_to_finish()
# 需要子类实现的具体评估逻辑
func evaluate_actions() -> Dictionary:
	return {"action": null, "target_position": Vector2i(-1, -1)}
