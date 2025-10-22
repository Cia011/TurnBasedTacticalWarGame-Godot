class_name WorldGrid

#基本属性
var name : String
var type : String

#寻路
var grid_position : Vector2i
var move_cost : int = 1

#角色
# var unit:Unit
# var is_obstacle : bool = false
# func is_occupied_by_unit():
# 	return unit != null

#离开----由大地图队伍触发
func exit_grid():
	print("[WorldGrid] "+"离开" + str(grid_position))

#进入
func enter_grid():
	print("[WorldGrid] "+"进入" + str(grid_position))
	#尝试触发事件
	WorldEventManager.trigger_event(grid_position)
	
# # 序列化网格数据
# func serialize() -> Dictionary:
# 	var data = {}
# 	data["grid_position"] = grid_position
# 	return data
# # 恢复网格数据
# func deserialize(data:Dictionary):
# 	grid_position = data["grid_position"]
