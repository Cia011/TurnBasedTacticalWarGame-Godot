extends Node

var units:Array[Unit]

#判断胜利条件
var our_side:Array[Unit]
var enemy_side:Array[Unit]


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
		pass
	elif enemy_side.is_empty():
		print("胜利")
		pass
	
func unit_die(unit:Unit):
	unregister_unit(unit)
	unit.queue_free()
	if BattleTurnManager.current_unit == unit||BattleTurnManager.current_unit==null:
		BattleTurnManager.set_next_turn_unit()
	
