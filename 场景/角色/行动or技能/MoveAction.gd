extends BaseAction
class_name MoveAction

var path : Array[Vector2i]
var move_speed : float = 100
var finish_grid_position :Vector2i
func _ready() -> void:
	super._ready()
	is_need_target = true
	is_instant = false
func start_action(target_grid_position:Vector2i,on_action_finished:Callable):
	super.start_action(target_grid_position,on_action_finished)
	#path = BattleGridManager.get_nav_grid_path(unit.grid_position,target_grid_position)
	path = BattleGridManager.D_get_nav_grid_path(unit.grid_position,target_grid_position)["path"]
	path.pop_front()#删去自身所在位置
	if path and not path.is_empty():
		#print("路径长度为:"+BattleGridManager.data_layer.a_star._compute_cost(path.front(),path.back()))
		
		#删除开始网格上的自身信息
		BattleGridManager.set_grid_occupied(unit.grid_position,null)
		#设置最终目标
		finish_grid_position = path.back()
		
		move(path.front())
	else:
		finish_action()
var move_duration = 0.1
var jump_height = 10

func move(target_cell: Vector2i):
	var start_pos = unit.position
	var target_pos = BattleGridManager.get_world_position(target_cell)
	
	#------------move开始时触发Grid的离开函数(未实现)------------
	BattleGridManager.get_grid_data(unit.grid_position).exit_grid(unit)
	
	
	
	#BattleGridManager.data_layer.grid_data_dict[unit.grid_position]

	# 创建两个并行的 Tween：一个用于水平移动，一个用于跳跃
	var tween = create_tween()
	# 水平移动
	tween.tween_property(unit, "position", target_pos, move_duration)
	# 跳跃动画（先上后下）
	#tween.parallel().tween_method(jump_animation, 0.0, 1.0, move_duration)
	tween.finished.connect(on_move_finished.bind(target_pos))
	
func on_move_finished(target_pos:Vector2i):
	#------------单个move结束时触发Grid的进入函数(未实现)------------
	BattleGridManager.get_grid_data(unit.grid_position).enter_grid(unit)
	
	#计算行动力消耗
	var current_action_points:int = unit.get_action_points()-cost
	unit.set_action_points(current_action_points)
	
	path.pop_front()
	unit.position = target_pos
	BattleGridManager.visulize_grids(get_action_grids() ,grid_color)
	if path and not path.is_empty():
		move(path.front())
	else:
		finish_action()

func finish_action()->void:
	super.finish_action()
	#设置最终目标网格自身信息
	BattleGridManager.set_grid_occupied(finish_grid_position,unit)
	
	
func jump_animation(t: float):
	var height = sin(PI * t) * jump_height
	unit.position.y = unit.position.y - height  # 需要存储original_y

func get_action_grids(unit_grid:Vector2i = unit.grid_position)->Array[Vector2i]:
	var results:Array[Vector2i] = []
	#results = BattleGridManager.D_get_all_path(unit_grid,max_length)["reachable"]
	results = BattleGridManager.D_get_all_path(unit_grid,unit.get_action_points())["reachable"]
	
	
	var deletes:Array[Vector2i]
	for grid in results:
		if BattleGridManager.is_grid_occupied(grid):
			deletes.append(grid)
	
	for delete in deletes:
		results.erase(delete)
	return results
