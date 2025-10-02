class_name BattleGrid

#基本属性
var name : String
var type : String

#寻路
var grid_position : Vector2i
var move_cost : int = 1


var unit:Unit	#判断格子上是否有角色
var is_obstacle : bool = false	#存在障碍

#判断格子上是否有角色
func is_occupied_by_unit():
	return unit != null
#当角色进入时触发
func enter_grid(unit:Unit):
	pass
func exit_grid(unit:Unit):
	pass
