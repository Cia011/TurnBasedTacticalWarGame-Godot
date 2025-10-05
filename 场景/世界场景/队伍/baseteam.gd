extends Node2D
class_name BaseTeam
var grid_position : Vector2i:
	get: return WorldGridManager.get_grid_position(position)
func _ready() -> void:
	GameState.baseteam_node = self
	position = WorldGridManager.get_world_position(WorldGridManager.get_grid_position(position))
	
	
var path : Array[Vector2i]
var is_moveing : bool = false
var move_duration = 1
var jump_height = 10



func _unhandled_input(event: InputEvent) -> void:
	
	#在UI界面时忽视队伍的移动
	if UiManager.have_ui_opening():
		return
	
	
	if event.is_action_pressed("left_mouse_clik"):
		
		get_path_and_try_move(WorldGridManager.get_mouse_grid_position())



func get_path_and_try_move(mouse_grid_position:Vector2i):
	if not path.is_empty():
		var target_grid_position = path.front()
		path.clear()
		path.append(target_grid_position)
		return
	var target_grid_position = mouse_grid_position
	path = WorldGridManager.get_nav_grid_path(grid_position,target_grid_position)
	path.pop_front()
	if not path.is_empty():
		move(path.front())

func move(target_cell: Vector2i):
	var start_pos = position
	var target_pos = WorldGridManager.get_world_position(target_cell)

	#move开始时触发当前Grid的离开函数(未实现)
	WorldGridManager.data_layer.grid_data_dict[grid_position].exit_grid()
	#BattleGridManager.data_layer.grid_data_dict[unit.grid_position]

	# 创建两个并行的 Tween：一个用于水平移动，一个用于跳跃
	var tween = create_tween()
	# 水平移动
	tween.tween_property(self, "position", target_pos, move_duration)
	tween.finished.connect(on_move_finished.bind(target_pos))
	
func on_move_finished(target_pos:Vector2i):
	path.pop_front()
	position = target_pos
	#move结束时触发目标Grid的进入函数(未实现)
	WorldGridManager.data_layer.grid_data_dict[grid_position].enter_grid()
	#触发目标Grid的事件
	
	
	if path and not path.is_empty():
		move(path.front())
	else:
		pass
