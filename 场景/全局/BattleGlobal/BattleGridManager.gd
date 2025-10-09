extends Node

var data_layer : TileMapLayer	#在battle地图里的data_layer节点赋值
var virulize_layer : TileMapLayer	#在战斗地图根节点BattleMap赋值


#不想要使用全局坐标了,因为TileMapLayer节点是固定在(0,0)上的
func get_world_position(grid_position:Vector2i) -> Vector2:
	#return data_layer.to_global(data_layer.map_to_local(grid_position))
	return data_layer.map_to_local(grid_position)
	
func get_grid_position(global_position:Vector2) -> Vector2i:
	#return data_layer.local_to_map(data_layer.to_local(global_position))
	return data_layer.local_to_map(global_position)

func get_mouse_world_position()-> Vector2:
	return data_layer.get_global_mouse_position()
	
func get_mouse_grid_position()-> Vector2i:
	return get_grid_position(get_mouse_world_position())
#获取地块数据集
func get_grid_data_dict()->Dictionary[Vector2i,BattleGrid]:
	return data_layer.grid_data_dict
#获取指定地块数据
func get_grid_data(grid_position:Vector2i)->BattleGrid:
	return get_grid_data_dict().get(grid_position)
func get_used_rect()->Rect2i:
	return data_layer.get_used_rect()
	
func get_grid_unit(grid_position:Vector2i)->Unit:
	if is_valid_grid(grid_position):
		return get_grid_data(grid_position).unit
	else:
		return null
# =================Astar寻路======================

#获取路径(grid路径)
func get_nav_grid_path(start_grid_position:Vector2i,end_grid_position:Vector2i)->Array[Vector2i]:
	return data_layer.a_star.get_id_path(start_grid_position,end_grid_position)
#获取路径(world路径)
func get_nav_world_path(start_grid_position:Vector2i,end_grid_position:Vector2i)->Array[Vector2]:
	var grid_path := get_nav_grid_path(start_grid_position,end_grid_position)
	var world_path : Array[Vector2] = []
	for grid_position in grid_path :
		var world_position := get_world_position(grid_position)
		world_path.append(world_position)
	return world_path
#将a_star中的某网格设置为不可移动
func set_point_solid(id: Vector2i, solid: bool = true):
	data_layer.a_star.set_point_solid(id,solid)
#获取路径长度
#简单长度,无权重
func  get_grid_path_length(grid_path:Array[Vector2i]) -> float:
	if grid_path.size() <= 0:
		return 0
	var length:float = 0
	for i in range(1,grid_path.size()):
		if grid_path[i-1].x != grid_path[i].x and grid_path[i-1].y != grid_path[i].y:
			length += 1.4
		else:
			length += 1
	return length
# =======================================

# =================Dijkstra寻路======================
#给定起始点与目标点 寻找路径
#返回{"path":Array[Vector2i], "cost": int}类型的字典
func D_get_nav_grid_path(start_grid_position:Vector2i,end_grid_position:Vector2i)->Dictionary:
	var grids:Array[Array]
	grids = Dijkstra._build_grid(get_used_rect(),get_grid_data_dict())
	var result:Dictionary =  Dijkstra.find_path(grids,start_grid_position,end_grid_position)
	return result
#获取所有路径
# # 		所有可达位置   #每个位置的成本  #到每个位置的路径
#返回result = {"reachable": [],"costs": {},"paths": {}}
func D_get_all_path(start: Vector2i, max_cost: float = INF)-> Dictionary:
	var grids:Array[Array]
	grids = Dijkstra._build_grid(get_used_rect(),get_grid_data_dict())
	var result:Dictionary = Dijkstra.find_all_paths(grids,start,max_cost)
	return result


#根据传入的数组高亮格子
func visulize_grids(grids : Array[Vector2i],color:Color = Color.WHITE)->void:
	virulize_layer.clear()
	virulize_layer.modulate = color
	virulize_layer.set_cells_terrain_connect(grids,0,0)

#判断目标格子是否是合法的(在grid_data_dict中注册的)
func is_valid_grid(grid_position : Vector2i) -> bool:
	return data_layer.grid_data_dict.has(grid_position)

#判断目标格子是否被单位占据
func is_grid_occupied(grid_position : Vector2i) -> bool:
	return is_valid_grid(grid_position) and data_layer.grid_data_dict[grid_position].is_occupied_by_unit()
#获取占据格子的单位
func get_grid_occupied(grid_position : Vector2i) -> Unit:
	if not is_valid_grid(grid_position):
		return null
	if not get_grid_data_dict().has(grid_position):
		return null
	return data_layer.grid_data_dict[grid_position].unit
#设置占据格子的单位
func set_grid_occupied(grid_position : Vector2i,unit:Unit)->void:
	if not is_valid_grid(grid_position):
		return
	data_layer.grid_data_dict[grid_position].unit = unit
	
#寻找邻居地块
func find_neighbors_cell(cell:Vector2i) -> Array[Vector2i]:
	var neighbors_offset : Array[Vector2i] =[Vector2i(0,1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(1,0)]
	var neighbors : Array[Vector2i]
	for offset in neighbors_offset:
		var neighbor_position :Vector2i = offset+cell
		if(is_valid_grid(neighbor_position)):
			neighbors.append(neighbor_position)
	return neighbors

func BFS_find_first_not_occupied_gird(grid_position : Vector2i)->Vector2i:
	var 待寻路 : Array[Vector2i] = []
	var finish_grid_positions:Array[Vector2i] = []
	待寻路.append(grid_position)
	while(!待寻路.is_empty()):
		var current_grid_position:Vector2i = 待寻路.front()
		if not is_grid_occupied(current_grid_position):
			return current_grid_position
		待寻路.pop_front()
		finish_grid_positions.append(current_grid_position)
		var neighbor_grid_positions : Array[Vector2i]
		neighbor_grid_positions = find_neighbors_cell(current_grid_position)
		for neighbor in neighbor_grid_positions:
			if finish_grid_positions.has(neighbor):
				continue
			待寻路.append(neighbor)
	return grid_position
