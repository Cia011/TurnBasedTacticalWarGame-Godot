extends Node

var units:Array[Unit]

#判断胜利条件
var our_side:Array[Unit]
var enemy_side:Array[Unit]
var battle_end : bool = false

#角色在创建时自动注册在units内
func register_unit(unit:Unit) -> void:
	units.append(unit)
	if unit.is_teammate:
		our_side.append(unit)
	else:
		enemy_side.append(unit)

	unit.unit_die.connect(unit_die)
	print(units)

func unregister_unit(unit:Unit) -> void:
	units.erase(unit)
	if unit.is_teammate:
		our_side.erase(unit)
	else:
		enemy_side.erase(unit)
	#失败
	if our_side.is_empty():
		battle_end = true
		print("-----战斗失败-----")
		show_final_ui("战斗失败","战斗失败")
	#胜利
	elif enemy_side.is_empty():
		print("-----战斗胜利-----")
		battle_end = true
		show_final_ui("战斗胜利","战斗胜利")
func show_final_ui(title:String,text:String):
	var FinalUI = UiManager.get_ui("FinalUI")
	FinalUI.set_up(title,text)
func unit_die(unit:Unit):
	unregister_unit(unit)
	BattleGridManager.set_grid_occupied(unit.grid_position, null)
	if BattleTurnManager.current_unit == unit||BattleTurnManager.current_unit==null:
		print("死亡重新选择角色")
		BattleTurnManager.set_next_turn_unit()
	unit.queue_free()
