extends Node
class_name BaseAI

var unit: Unit
var action_manager: ActionsManager
var current_grid_position: Vector2i

# 决策信号
signal decision_made(action: BaseAction, target_position: Vector2i)
signal turn_completed()

# 异步思考相关
var _is_thinking: bool = false
var _current_decision: Dictionary
var _evaluation_state: Dictionary = {}  # 用于保存评估状态

func _init(unit: Unit) -> void:
	self.unit = unit
	action_manager = unit.action_manager

# 主决策函数 - 改进的异步版本
func take_turn() -> void:
	var action_count = 0
	var max_actions_per_turn = 5  # 防止无限循环的安全限制
	
	print(unit.unit_data.character_name + " 开始回合，行动力: " + str(unit.get_action_points()))
	
	while unit.get_action_points() > 0 and action_count < max_actions_per_turn:
		action_count += 1
		current_grid_position = unit.get_grid_position()
		
		# 使用分帧异步评估，避免阻塞主线程
		var decision = await evaluate_actions_async_framed()
		
		# 检查决策是否有效
		if not decision.action or decision.target_position == Vector2i(-1, -1):
			print("没有找到有效行动")
			break
		
		# 检查行动力是否足够
		if unit.get_action_points() < decision.action.cost:
			print("行动力不足，无法执行: " + decision.action.action_name)
			break
		
		print("选择行动: " + decision.action.action_name + " 目标: " + str(decision.target_position))
		
		# 执行行动并等待完成
		await execute_action(decision.action, decision.target_position)
	
	print(unit.unit_data.character_name + " 回合结束")
	turn_completed.emit()
	skip_turn()

# 改进的异步评估 - 使用分帧处理避免卡顿
func evaluate_actions_async_framed() -> Dictionary:
	if _is_thinking:
		await get_tree().process_frame  # 让出一帧避免阻塞
	
	_is_thinking = true
	
	# 重置评估状态
	_evaluation_state = {
		"current_action_index": 0,
		"best_decision": {"action": null, "target_position": Vector2i(-1, -1), "score": -INF},
		"actions": action_manager.actions.duplicate()
	}
	
	# 分帧评估所有行动
	while _evaluation_state.current_action_index < _evaluation_state.actions.size():
		var decision = await evaluate_single_action_framed()
		if decision.score > _evaluation_state.best_decision.score:
			_evaluation_state.best_decision = decision
		
		# 每评估一个行动就让出一帧
		await get_tree().process_frame
	
	_is_thinking = false
	return _evaluation_state.best_decision

# 分帧评估单个行动
func evaluate_single_action_framed() -> Dictionary:
	if _evaluation_state.current_action_index >= _evaluation_state.actions.size():
		return {"action": null, "target_position": Vector2i(-1, -1), "score": -INF}
	
	var action = _evaluation_state.actions[_evaluation_state.current_action_index]
	_evaluation_state.current_action_index += 1
	
	# 检查行动力是否足够
	if not can_afford_action(action):
		return {"action": null, "target_position": Vector2i(-1, -1), "score": -INF}
	
	var best_score = -INF
	var best_target = Vector2i(-1, -1)
	
	if action.is_need_target:
		# 获取行动范围
		var action_grids = action.get_action_grids(current_grid_position)
		
		# 分帧评估每个目标位置
		for i in range(action_grids.size()):
			var target_grid = action_grids[i]
			var score = evaluate_action_target(action, target_grid)
			
			# 应用行动力消耗考虑
			score = evaluate_action_with_cost(action, score)
			
			if score > best_score:
				best_score = score
				best_target = target_grid
			
			# 每评估3个目标就让出一帧，避免卡顿
			if i > 0 and i % 3 == 0:
				await get_tree().process_frame
	else:
		# 不需要目标的行动
		var score = evaluate_self_action(action)
		# 应用行动力消耗考虑
		score = evaluate_action_with_cost(action, score)
		best_score = score
		best_target = current_grid_position
	
	return {"action": action, "target_position": best_target, "score": best_score}

# 执行行动
func execute_action(action: BaseAction, target_position: Vector2i) -> void:
	# 可视化行动范围
	BattleGridManager.visulize_grids(action.get_action_grids(current_grid_position), action.grid_color)
	
	# 执行行动并等待完成
	BattleActionManager.perform_action(action, target_position)
	await action.action_finished
	
	print("行动执行完成")

func skip_turn() -> void:
	print(unit.unit_data.character_name + " 跳过回合")
	BattleTurnManager.set_next_turn_unit()
	turn_completed.emit()

# 清理资源
func _exit_tree():
	# 移除线程相关清理代码
	pass

# ========== 基础评估方法（需要子类重写） ==========

# 检查行动是否可执行
func can_afford_action(action: BaseAction) -> bool:
	return unit.get_action_points() >= action.cost

# 评估行动时考虑行动力消耗
func evaluate_action_with_cost(action: BaseAction, base_score: float) -> float:
	if not can_afford_action(action):
		return -1000.0  # 无法执行的行动给极低分数
	
	var cost_ratio = float(action.cost) / unit.get_action_points()
	var cost_penalty = cost_ratio * 20.0  # 消耗越高，惩罚越大
	
	return base_score - cost_penalty

# 需要子类实现的具体评估逻辑
func evaluate_actions() -> Dictionary:
	push_error("BaseAI.evaluate_actions() 需要被子类重写!")
	return {"action": null, "target_position": unit.get_grid_position()}

# 评估针对目标的行动
func evaluate_action_target(action: BaseAction, target_grid: Vector2i) -> float:
	return 0.0  # 需要子类实现

# 评估自身行动
func evaluate_self_action(action: BaseAction) -> float:
	return 0.0  # 需要子类实现
