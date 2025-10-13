extends BaseAI
class_name AggressiveEnemyAI

# 重写评估方法 - 与新的异步架构兼容
func evaluate_actions() -> Dictionary:
	var player_units: Array[Unit] = BattleUnitManager.our_side
	var best_decision = {"action": null, "target_position": Vector2i(-1, -1), "score": -INF}
	
	# 首先评估所有非移动行动
	for action in action_manager.actions:
		if not (action is MoveAction):
			var decision = evaluate_single_action(action)
			if decision.score > best_decision.score:
				best_decision = decision
	
	# 如果没有找到好的非移动行动，或者分数很低，考虑移动
	if best_decision.score < 10 or best_decision.action == null:
		var move_action = get_move_action()
		if move_action:
			var move_decision = evaluate_move_strategy(move_action, player_units)
			if move_decision.score > best_decision.score:
				best_decision = move_decision
	
	return best_decision

# 评估单个行动 - 修复bug：添加参数检查
func evaluate_single_action(action: BaseAction) -> Dictionary:
	var best_score = -INF
	var best_target = Vector2i(-1, -1)
	
	# 检查行动力是否足够
	if not can_afford_action(action):
		return {"action": null, "target_position": Vector2i(-1, -1), "score": -INF}
	
	if action.is_need_target:
		# 获取行动范围
		var action_grids = action.get_action_grids(current_grid_position)
		
		for target_grid in action_grids:
			var score = evaluate_action_target(action, target_grid)
			# 应用行动力消耗考虑
			score = evaluate_action_with_cost(action, score)
			if score > best_score:
				best_score = score
				best_target = target_grid
	else:
		var score = evaluate_self_action(action)
		# 应用行动力消耗考虑
		score = evaluate_action_with_cost(action, score)
		best_score = score
		best_target = current_grid_position
	
	return {"action": action, "target_position": best_target, "score": best_score}

# 评估目标行动
func evaluate_action_target(action: BaseAction, target_grid: Vector2i) -> float:
	var score = 0.0
	# 检查目标位置是否有玩家单位
	var target_unit: Unit = BattleGridManager.get_grid_occupied(target_grid)
	
	if target_unit and target_unit.is_teammate:
		# 根据行动类型评分
		if action is AttackAction:
			score += evaluate_attack_action(action, target_unit)
		elif action is MagicAttackAction:
			score += evaluate_magic_action(action, target_unit)
		# 可以添加其他行动类型的评估
	return score

# 评估攻击行动
func evaluate_attack_action(action: BaseAction, target_unit: Unit) -> float:
	var score = 0.0
	
	# 基础伤害评估
	var estimated_damage = estimate_damage(action,target_unit)
	score += estimated_damage * 2.0
	
	# 击杀奖励
	if will_kill_target(estimated_damage, target_unit):
		score += 50.0
	
	# 距离因素 - 优先攻击近距离目标
	var distance = current_grid_position.distance_to(target_unit.get_grid_position())
	score += (10.0 - distance) * 0.5
	
	return score

# 评估魔法行动
func evaluate_magic_action(action: BaseAction, target_unit: Unit) -> float:
	var score = 0.0
	var estimated_damage = estimate_magic_damage(action,target_unit)
	score += estimated_damage * 1.5  # 魔法攻击通常有额外效果
	
	if will_kill_target(estimated_damage, target_unit):
		score += 40.0
	
	return score

# 评估自身行动
func evaluate_self_action(action: BaseAction) -> float:
	var score = 0.0
	return score

# 移动策略评估
func evaluate_move_strategy(move_action: MoveAction, player_units: Array) -> Dictionary:
	var best_move_score = -INF
	var best_move_target = current_grid_position  # 默认停留在当前位置，而不是(-1,-1)
	
	# 获取所有可移动的位置
	var move_grids = move_action.get_action_grids(current_grid_position)
	
	# 如果没有可移动位置，返回当前位置
	if move_grids.is_empty():
		return {
			"action": move_action, 
			"target_position": current_grid_position, 
			"score": -1000.0  # 无法移动的惩罚分数
		}
	
	for target_grid in move_grids:
		# 跳过当前位置（如果已经在当前位置，不需要移动）
		if target_grid == current_grid_position:
			continue
			
		# 评估移动到这个位置的价值
		var move_score = evaluate_move_action(move_action, target_grid, player_units)
		
		# 额外考虑：移动后是否能执行更好的攻击
		move_score += evaluate_post_move_actions(target_grid, player_units)
		
		if move_score > best_move_score:
			best_move_score = move_score
			best_move_target = target_grid
	
	# 如果所有移动位置分数都很低，至少选择一个相对较好的位置
	if best_move_score <= -INF + 1:  # 防止浮点数精度问题
		# 选择距离玩家最近的位置
		var closest_position = current_grid_position
		var min_distance = INF
		for target_grid in move_grids:
			var distance = get_min_distance_to_players(target_grid, player_units)
			if distance < min_distance:
				min_distance = distance
				closest_position = target_grid
		best_move_target = closest_position
		best_move_score = -min_distance  # 距离越近分数越高
	
	return {
		"action": move_action, 
		"target_position": best_move_target, 
		"score": best_move_score
	}

# 评估移动行动
func evaluate_move_action(action: BaseAction, target_grid: Vector2i, player_units: Array) -> float:
	var score = 0.0
	
	# 基础移动评分 - 基于距离玩家单位的远近
	var min_distance_to_player = get_min_distance_to_players(target_grid, player_units)
	
	# 防止INF距离导致的异常
	if min_distance_to_player == INF:
		min_distance_to_player = 100.0  # 设置一个较大的默认距离
	
	# 距离越近，分数越高（攻击型AI）
	# 使用对数函数避免距离差异过大导致的分数跳跃
	score += max(20.0 - min_distance_to_player, 0.0) * 2.0
	# 考虑地形优势
	score += evaluate_terrain_advantage(target_grid)
	
	# 避免危险位置（如被多个玩家单位包围）
	
	# var danger_level = evaluate_danger_level(target_grid, player_units)
	# score -= danger_level * 10.0  # 增加危险惩罚
	
	# 避免移动到边界或无效位置
	if target_grid.x < 0 or target_grid.y < 0:
		score -= 5000.0
	
	return score

func evaluate_post_move_actions(new_position: Vector2i, player_units: Array) -> float:
	var bonus_score = 0.0
	
	# 模拟移动到新位置后，评估能执行的行动
	var original_position = current_grid_position
	current_grid_position = new_position  # 临时改变位置
	
	# 评估所有非移动行动在新位置的价值
	for action in action_manager.actions:
		if not (action is MoveAction) and action.is_need_target:
			var action_grids = action.get_action_grids(new_position)
			for target_grid in action_grids:
				var target_unit = BattleGridManager.get_grid_occupied(target_grid)
				if target_unit and target_unit.is_teammate:
					var action_score = evaluate_action_target(action, target_grid)
					if action_score > bonus_score:
						bonus_score = action_score
	
	# 恢复原始位置
	current_grid_position = original_position
	
	# 确保不会返回负值
	return max(bonus_score * 0.7, 0.0)  # 给移动后行动的价值打折，因为需要额外行动点

# ========== 工具函数 ==========

func get_move_action() -> MoveAction:
	for action in action_manager.actions:
		if action is MoveAction:
			return action
	return null

# 检查行动是否可执行
func can_afford_action(action: BaseAction, additional_cost: int = 0) -> bool:
	var total_cost = action.cost + additional_cost
	return unit.get_action_points() >= total_cost

# 评估行动时考虑行动力消耗
func evaluate_action_with_cost(action: BaseAction, base_score: float) -> float:
	if not can_afford_action(action):
		return -1000.0  # 无法执行的行动给极低分数
	
	var cost_ratio = float(action.cost) / unit.get_action_points()
	var cost_penalty = cost_ratio * 5  # 消耗越高，惩罚越大
	
	return base_score - cost_penalty

# 获取最小距离到玩家
func get_min_distance_to_players(position: Vector2i, player_units: Array) -> float:
	var min_distance = INF
	
	# 如果没有玩家单位，返回一个较大的默认距离
	if player_units.is_empty():
		return 10.0
	
	for player in player_units:
		# 确保玩家单位有效
		if player and is_instance_valid(player):
			var player_pos = player.get_grid_position()
			# 使用曼哈顿距离或欧几里得距离
			var distance = position.distance_to(player_pos)
			if distance < min_distance:
				min_distance = distance
	
	# 防止返回INF
	if min_distance == INF:
		min_distance = 100.0
	
	return min_distance

func evaluate_terrain_advantage(position: Vector2i) -> float:
	return 0.0  # 暂时返回0，需要根据实际地形系统实现

func evaluate_danger_level(position: Vector2i, player_units: Array) -> float:
	var danger = 0.0
	# 计算被多少玩家单位威胁
	for player in player_units:
		if can_player_attack_position(player, position):
			danger += 1.0
	return danger

func can_player_attack_position(player: Unit, position: Vector2i) -> bool:
	# 检查玩家是否有行动能攻击到这个位置
	if player.action_manager:
		for action in player.action_manager.actions:
			if action is AttackAction or action is MagicAttackAction:
				var attack_range = action.get_action_grids(player.get_grid_position())
				if position in attack_range:
					return true
	return false

# 工具函数
func estimate_damage(action: BaseAction, target_unit: Unit) -> int:
	var attacker_strength : int
	# 考虑武器伤害加成
	if action is AttackAction:
		attacker_strength += action.damage
	return max(attacker_strength, 1)

func estimate_magic_damage(action: BaseAction,target_unit: Unit) -> int:
	var attacker_intelligence = unit.get_stat("intelligence")
	var target_defense = target_unit.get_stat("defense")
	return max(action.damage, 1)
	#return max(attacker_intelligence - target_defense / 2, 1)

func will_kill_target(damage: int, target_unit: Unit) -> bool:
	return target_unit.get_stat("current_health") <= damage

func get_mana_cost(action: BaseAction) -> int:
	if action is MagicAttackAction:
		return 10  # 假设魔法攻击消耗10点魔法值
	return 0
