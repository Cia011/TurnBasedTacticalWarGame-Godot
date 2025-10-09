extends BaseAI
class_name AggressiveEnemyAI

func evaluate_actions() -> Dictionary:
	var best_score = -INF
	var best_action = null
	var best_target = Vector2i(-1, -1)
	
	#var player_units = get_tree().get_nodes_in_group("player_units")
	var player_units:Array[Unit] = BattleUnitManager.our_side
	# 首先评估所有非移动行动
	for action in action_manager.actions:
		if not (action is MoveAction):
			 # 检查行动力是否足够
			if not can_afford_action(action):
				continue
			var action_grids = action.get_action_grids(test_grid_position)
			if action.is_need_target:
				for target_grid in action_grids:
					var target_unit = BattleGridManager.get_grid_occupied(target_grid)
					#if target_unit and target_unit.is_in_group("player_units"):
					if target_unit and target_unit.is_teammate:
						var score = evaluate_action_target(action, target_grid, player_units) * 5
						 # 应用行动力消耗考虑
						score = evaluate_action_with_cost(action, score)
						if score > best_score:
							best_score = score
							best_action = action
							best_target = target_grid
			else:
				var score = evaluate_self_action(action, player_units)
				# 应用行动力消耗考虑
				score = evaluate_action_with_cost(action, score)
				if score > best_score:
					best_score = score
					best_action = action
					best_target = test_grid_position
	
	# 如果没有找到好的非移动行动，或者分数很低，考虑移动
	if best_score < 5 or best_action == null:  # 阈值可以根据需要调整
		var move_action = get_move_action()
		if move_action:
			var move_decision = evaluate_move_strategy(move_action, player_units)
			if move_decision.score > best_score:
				best_score = move_decision.score
				best_action = move_decision.action
				best_target = move_decision.target_position
	return {"action": best_action, "target_position": best_target, "score": best_score}

func evaluate_action_target(action: BaseAction, target_grid: Vector2i, player_units: Array) -> float:
	var score = 0.0
	# 检查目标位置是否有玩家单位
	var target_unit:Unit = BattleGridManager.get_grid_occupied(target_grid)
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
	#行动力不足则不考虑
	if unit.get_action_points()<action.cost:
		score = -INF
	# 基础伤害评估
	var estimated_damage = estimate_damage(target_unit)
	score += estimated_damage * 2.0
	
	# 击杀奖励
	if will_kill_target(estimated_damage, target_unit):
		score += 50.0
	
	# 距离因素 - 优先攻击近距离目标
	var distance = test_grid_position.distance_to(target_unit.get_grid_position())
	score += (10.0 - distance) * 0.5
	
	return score

# 评估魔法行动
func evaluate_magic_action(action: BaseAction, target_unit: Unit) -> float:
	var score = 0.0
	#行动力不足则不考虑
	if unit.get_action_points()<action.cost:
		score = -INF
	# 检查魔法值是否足够
	#if unit.data_manager.get_stat("current_mana") < get_mana_cost(action):
		#return -100.0  # 魔法值不足，大幅扣分
	
	var estimated_damage = estimate_magic_damage(target_unit)
	score += estimated_damage * 1.5  # 魔法攻击通常有额外效果
	
	if will_kill_target(estimated_damage, target_unit):
		score += 40.0
	
	return score

# 评估自身行动（如治疗、buff）
func evaluate_self_action(action: BaseAction, player_units: Array) -> float:
	var score = 0.0
	
	## 生命值低时，治疗行动得分高
	#var health_ratio = float(unit.data_manager.get_stat("current_health")) / unit.data_manager.get_stat("max_health")
	#
	#if action is HealAction and health_ratio < 0.5:
		#score += (1.0 - health_ratio) * 30.0
	
	return score

# 添加移动相关评估方法
func evaluate_move_action(action: BaseAction, target_grid: Vector2i, player_units: Array) -> float:
	var score = 0.0
	# 基础移动评分 - 基于距离玩家单位的远近
	var min_distance_to_player = get_min_distance_to_players(target_grid, player_units)
	# 距离越近，分数越高（攻击型AI）
	score += (10.0 - min_distance_to_player) * 5.0
	# 考虑地形优势
	score += evaluate_terrain_advantage(target_grid)
	# 避免危险位置（如被多个玩家单位包围）
	score -= evaluate_danger_level(target_grid, player_units) * 3.0
	# 考虑移动消耗的行动点
	var move_cost = estimate_move_cost(action, test_grid_position, target_grid)
	var remaining_ap = unit.get_action_points() - move_cost
	
	# 如果移动后还能执行其他行动，加分
	if remaining_ap > 0:
		score += 15.0
	
	return score
func get_move_action() -> MoveAction:
	for action in action_manager.actions:
		if action is MoveAction:
			return action
	return null
#预测移动策略
func evaluate_move_strategy(move_action: MoveAction, player_units: Array) -> Dictionary:
	var best_move_score = -INF
	var best_move_target = Vector2i(-1, -1)
	
	# 获取所有可移动的位置
	var move_grids = move_action.get_action_grids(test_grid_position)
	print("当前可移动位置:"+str(move_grids))
	for target_grid in move_grids:
		# 评估移动到这个位置的价值
		var move_score = evaluate_move_action(move_action, target_grid, player_units)
		
		# 额外考虑：移动后是否能执行更好的攻击
		move_score += evaluate_post_move_actions(target_grid, player_units)
		
		if move_score > best_move_score:
			best_move_score = move_score
			best_move_target = target_grid
	
	return {
		"action": move_action, 
		"target_position": best_move_target, 
		"score": best_move_score
	}
func evaluate_post_move_actions(new_position: Vector2i, player_units: Array) -> float:
	var bonus_score = 0.0
	
	# 模拟移动到新位置后，评估能执行的行动
	var original_position = test_grid_position
	test_grid_position = new_position  # 临时改变位置
	
	# 评估所有非移动行动在新位置的价值
	for action in action_manager.actions:
		if not (action is MoveAction) and action.is_need_target:
			var action_grids = action.get_action_grids(new_position)
			for target_grid in action_grids:
				var target_unit = BattleGridManager.get_grid_occupied(target_grid)
				if target_unit and target_unit.is_teammate:
					var action_score = evaluate_action_target(action, target_grid, player_units)
					if action_score > bonus_score:
						bonus_score = action_score
	
	# 恢复原始位置
	test_grid_position = original_position
	
	return bonus_score * 0.7  # 给移动后行动的价值打折，因为需要额外行动点
# 评估针对特定目标的行动
func get_min_distance_to_players(position: Vector2i, player_units: Array) -> float:
	var min_distance = INF
	for player in player_units:
		var distance = position.distance_to(player.get_grid_position())
		if distance < min_distance:
			min_distance = distance
	return min_distance

func evaluate_terrain_advantage(position: Vector2i) -> float:
	# 获取格子数据，评估地形优势
	var grid_data = BattleGridManager.get_grid_data(position)
	var advantage = 0.0
	
	## 假设格子数据有防御加成、高度优势等
	#if grid_data and grid_data.has_method("get_defense_bonus"):
		#advantage += grid_data.get_defense_bonus() * 2.0
	#
	## 高度优势
	#if grid_data and grid_data.has_method("get_height"):
		#advantage += grid_data.get_height() * 1.5
	
	return advantage

func evaluate_danger_level(position: Vector2i, player_units: Array) -> float:
	var danger = 0.0
	
	# 计算被多少玩家单位威胁
	for player in player_units:
		# 检查玩家是否能攻击到这个位置
		if can_player_attack_position(player, position):
			danger += 1.0
			
			# 如果玩家是远程单位，危险度更高
			if is_ranged_unit(player):
				danger += 0.5
	
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

func is_ranged_unit(unit: Unit) -> bool:
	# 检查是否是远程单位（根据单位类型或装备判断）
	# 这里需要根据您的游戏逻辑实现
	return false

func estimate_move_cost(action: BaseAction, start_pos: Vector2i, target_pos: Vector2i) -> int:
	# 估算移动消耗的行动点
	if action is MoveAction:
		# 使用A*路径计算实际消耗
		var path_data = BattleGridManager.D_get_nav_grid_path(start_pos, target_pos)
		if path_data and path_data.has("path"):
			return path_data["path"].size() - 1  # 减去起点
	return start_pos.distance_to(target_pos)  # 备用方案：使用直线距离
# 获取当前可用行动力
func get_available_action_points() -> int:
	return unit.get_action_points()
# 检查行动是否可执行（考虑行动力）
func can_afford_action(action: BaseAction, additional_cost: int = 0) -> bool:
	var total_cost = action.get_actual_cost() + additional_cost
	return get_available_action_points() >= total_cost
# 评估行动时考虑行动力消耗
func evaluate_action_with_cost(action: BaseAction, base_score: float) -> float:
	if not can_afford_action(action):
		return -1000.0  # 无法执行的行动给极低分数
	
	var cost_ratio = float(action.get_actual_cost()) / get_available_action_points()
	var cost_penalty = cost_ratio * 20.0  # 消耗越高，惩罚越大
	
	return base_score - cost_penalty
# 评估移动行动时考虑行动力
func evaluate_move_action_with_cost(action: BaseAction, target_grid: Vector2i, player_units: Array) -> float:
	var base_score = evaluate_move_action(action, target_grid, player_units)
	
	# 计算移动消耗
	var move_cost = estimate_move_cost(action, unit.get_grid_position(), target_grid)
	if not can_afford_action(action, move_cost):
		return -1000.0
	
	# 应用行动力消耗惩罚
	var total_cost = action.get_actual_cost() + move_cost
	var cost_ratio = float(total_cost) / get_available_action_points()
	var cost_penalty = cost_ratio * 25.0
	
	return base_score - cost_penalty
# 工具函数
func estimate_damage(target_unit: Unit) -> int:
	# 简化的伤害估算
	var attacker_strength = unit.get_stat("strength")
	var target_defense = target_unit.get_stat("defense")
	#return max(attacker_strength - target_defense, 1)
	return attacker_strength

#预测魔法伤害
func estimate_magic_damage(target_unit: Unit) -> int:
	var attacker_intelligence = unit.get_stat("intelligence")
	var target_defense = target_unit.get_stat("defense")
	#return max(attacker_intelligence - target_defense / 2, 1)
	return attacker_intelligence

func will_kill_target(damage: int, target_unit: Unit) -> bool:
	return target_unit.get_stat("current_health") <= damage

func get_mana_cost(action: BaseAction) -> int:
	if action is MagicAttackAction:
		return 10  # 假设魔法攻击消耗10点魔法值
	return 0
