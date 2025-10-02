extends BaseAction
class_name AttackAction

var max_length = 1

func _ready() -> void:
	super._ready()
	is_need_target = true
	is_instant = false

func start_action(target_grid_position:Vector2i,on_action_finished:Callable):
	super.start_action(target_grid_position,on_action_finished)
	if not is_actioning:
		return
	#攻击必须有目标
	if BattleGridManager.is_grid_occupied(target_grid_position):
		var target_unit:Unit = BattleGridManager.get_grid_occupied(target_grid_position)
		#具体攻击逻辑
		#target_unit.unit_data.current_health -= 10;
		#print(target_unit.unit_data.current_health)
		target_unit.data_manager.remove_final_bonus("current_health",10)
		print(target_unit.data_manager.get_stat("current_health"))
		unit.data_manager.remove_final_bonus("current_health",-20)
		
	#未实现攻击动画,直接结束行动
	finish_action()

func get_action_grids(unit_grid:Vector2i = unit.grid_position)->Array[Vector2i]:
	var results:Array[Vector2i] = []
	results = BattleGridManager.D_get_all_path(unit_grid,max_length)["reachable"]
	
	#var deletes:Array[Vector2i]
	#if is_need_target:
		#for grid in results:
			#if not BattleGridManager.is_grid_occupied(grid):
				#deletes.append(grid)
	#for delete in deletes:
		#results.erase(delete)
	
	#for i in range(-max_length,max_length+1):
		#for j in range(-max_length,max_length+1):
			#if i==0 and j==0:
				#continue
			#var potential_grid = unit_grid + Vector2i(i,j)
			#if not BattleGridManager.is_valid_grid(potential_grid):
				#continue
			#var grid_path = BattleGridManager.get_nav_grid_path(unit_grid,potential_grid)
			#var length = BattleGridManager.get_grid_path_length(grid_path)
			#if length <= max_length and length > 0:
				#results.append(potential_grid)
	return results
