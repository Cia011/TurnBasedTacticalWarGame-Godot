extends Node

# 敏捷制回合管理器
# 每个单位有一个"跑道"（长度 100），每 tick 按 agility 前进，
# 先到 100 的先行动，行动后扣 100 保留余数继续跑。
# 高敏捷单位可以多次行动，低敏捷单位偶尔行动一次。

var current_unit: Unit = null
var pre_unit: Unit = null
var TurnManager: Dictionary[Unit, float]

signal signal_change_unit(unit)
signal signal_turn_start(unit)
signal signal_turn_end(unit)


func set_up():
	for unit in BattleUnitManager.units:
		TurnManager[unit] = 0.0
	set_next_turn_unit()


# 选取下一个行动单位
func set_next_turn_unit():
	if BattleUnitManager.battle_end:
		return

	pre_unit = current_unit
	current_unit = null

	while current_unit == null:
		# 找出所有达到 100 的候选人
		var candidates: Array[Unit] = []
		for unit in BattleUnitManager.units:
			var val = TurnManager.get(unit, 0.0)
			if val >= 100.0:
				candidates.append(unit)

		if not candidates.is_empty():
			# 溢出值最高的优先行动（超出越多说明等待越久）
			candidates.sort_custom(func(a: Unit, b: Unit) -> bool:
				return TurnManager.get(a, 0.0) > TurnManager.get(b, 0.0)
			)
			select_unit(candidates[0])
			return

		# 无人达到 100 → 全体按敏捷前进
		for unit in BattleUnitManager.units:
			var agility = unit.unit_data.get_final_stat("agility")
			if agility > 0:
				TurnManager[unit] = TurnManager.get(unit, 0.0) + agility


# 预测接下来 N 个回合的行动顺序（不影响当前游戏状态）
func get_upcoming_turns(count: int) -> Array[Unit]:
	if count <= 0 or BattleUnitManager.units.is_empty():
		return []

	# 快照当前进度
	var snapshot: Dictionary = {}
	for unit in BattleUnitManager.units:
		snapshot[unit] = TurnManager.get(unit, 0.0)

	var active = BattleUnitManager.units.duplicate()
	var result: Array[Unit] = []

	while result.size() < count and not active.is_empty():
		# 每次 tick：全体前进
		for unit in active:
			var agi = unit.unit_data.get_final_stat("agility")
			if agi > 0:
				snapshot[unit] = snapshot.get(unit, 0.0) + agi

		# 找 >= 100 的候选人（至少有一个，因为刚加过）
		var candidates: Array[Unit] = []
		for unit in active:
			if snapshot.get(unit, 0.0) >= 100.0:
				candidates.append(unit)

		if candidates.is_empty():
			# 极端情况：所有单位 agility ≤ 0
			result.append(active[0])
			continue

		candidates.sort_custom(func(a: Unit, b: Unit) -> bool:
			return snapshot.get(a, 0.0) > snapshot.get(b, 0.0)
		)

		var chosen = candidates[0]
		snapshot[chosen] = snapshot.get(chosen, 0.0) - 100.0
		result.append(chosen)

	return result


func select_unit(unit: Unit) -> void:
	# 结束上一单位的回合
	if is_instance_valid(pre_unit):
		pre_unit.end_turn()
		signal_turn_end.emit(pre_unit)

	current_unit = unit
	TurnManager[unit] = TurnManager.get(unit, 0.0) - 100.0

	current_unit.start_turn()
	signal_turn_start.emit(current_unit)
	signal_change_unit.emit(unit)

	if current_unit.is_teammate:
		BattleActionManager.set_default_action()
