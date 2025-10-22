extends Node

var data_layer : TileMapLayer
var virulize_layer : TileMapLayer
## 获取世界坐标
func get_world_position(grid_position:Vector2i) -> Vector2:
	#return data_layer.to_global(data_layer.map_to_local(grid_position))
	return data_layer.map_to_local(grid_position)
## 获取网格坐标
func get_grid_position(global_position:Vector2) -> Vector2i:
	#return data_layer.local_to_map(data_layer.to_local(global_position))
	return data_layer.local_to_map(global_position)
## 获取鼠标世界坐标
func get_mouse_world_position()-> Vector2:
	return data_layer.get_global_mouse_position()
	## 获取鼠标网格坐标
func get_mouse_grid_position()-> Vector2i:
	return get_grid_position(get_mouse_world_position())

#从grid_data_dict中获取数据
## 获取网格数据字典
func get_grid_data_dict()->Dictionary[Vector2i,WorldGrid]:
	return data_layer.grid_data_dict
## 获取指定网格数据
func get_grid_data(grid_position:Vector2i)->WorldGrid:
	return get_grid_data_dict().get(grid_position)
## 获取已使用的矩形区域
func get_used_rect()->Rect2i:
	return data_layer.get_used_rect()
## 获取导航网格路径
func get_nav_grid_path(start_grid_position:Vector2i,end_grid_position:Vector2i)->Array[Vector2i]:
	return data_layer.a_star.get_id_path(start_grid_position,end_grid_position)
## 获取导航世界路径
func get_nav_world_path(start_grid_position:Vector2i,end_grid_position:Vector2i)->Array[Vector2]:
	var grid_path := get_nav_grid_path(start_grid_position,end_grid_position)
	var world_path : Array[Vector2] = []
	for grid_position in grid_path :
		var world_position := get_world_position(grid_position)
		world_path.append(world_position)
	return world_path
## 获取导航网格路径长度
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
## 可视化网格
func visulize_grids(grids : Array[Vector2i],color:Color = Color.WHITE)->void:
	virulize_layer.clear()
	virulize_layer.modulate = color
	virulize_layer.set_cells_terrain_connect(grids,0,0)
## 检查网格是否有效
func is_valid_grid(grid_position : Vector2i) -> bool:
	return data_layer.grid_data_dict.has(grid_position)
## 检查网格是否被占用
func is_grid_occupied(grid_position : Vector2i) -> bool:
	return is_valid_grid(grid_position) and data_layer.grid_data_dict[grid_position].is_occupied_by_unit()
## 获取网格上的单位
func get_grid_occupied(grid_position : Vector2i) -> Unit:
	if not is_valid_grid(grid_position):
		return null
	return data_layer.grid_data_dict[grid_position].unit
## 设置网格上的单位
func set_grid_occupied(grid_position : Vector2i,unit:Unit)->void:
	if not is_valid_grid(grid_position):
		return
	data_layer.grid_data_dict[grid_position].unit = unit
	
## 设置指定网格的地形
func set_grid(cell:Vector2i,source_id:int,atlas_coords:Vector2i)->void:
	data_layer.set_grid(cell,source_id,atlas_coords)
