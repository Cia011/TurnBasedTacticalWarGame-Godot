extends Node

var current_unit : Unit = null

var TurnManager : Dictionary[Unit,float]

#每个角色对应一个回合,当指定角色回合开始时,发送signal_change_unit信号
#执行 unit_action_ui 的 on_change_unit(unit:Unit) 函数 来生成 action卡片//即转换角色时自动更新UI卡片

signal signal_change_unit(unit)

signal signal_turn_start(unit)
signal signal_turn_end(unit)


func set_up():
	for unit in BattleUnitManager.units:
		TurnManager[unit] = 0
	#初始化结束后选择一个角色
	set_next_turn_unit()


#因为在BattleUnitManager.units中遍历,所以角色死亡可以直接在units里注销,而不用考虑对回合的影响
func set_next_turn_unit():
	current_unit = null
	while (current_unit == null):
		for unit in BattleUnitManager.units:
			if TurnManager[unit] >= 100:
				select_unit(unit)
				TurnManager[unit]-=100
				return
		for unit in BattleUnitManager.units:
			TurnManager[unit] += unit.unit_data.agility
			#if unit != null and TurnManager.get(unit):
				#TurnManager[unit] += unit.unit_data.agility
		



func select_unit(unit:Unit)->void:
	if current_unit == unit:
		return
	current_unit = unit
	print("select_unit" + str(unit))
	signal_change_unit.emit(unit)
	
	BattleActionManager.set_default_action()
	
