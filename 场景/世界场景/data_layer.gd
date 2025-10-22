extends TileMapLayer
var Noise1 :FastNoiseLite
var Noise2 :FastNoiseLite
var a_star : AStarGrid2D
var grid_data_dict : Dictionary[Vector2i,WorldGrid]
func _ready() -> void:
	WorldGridManager.data_layer = self
	a_star = AStarGrid2D.new()
	Noise1= FastNoiseLite.new()
	Noise2= FastNoiseLite.new()
	if (GameState.is_new_game):
		generate_random_map()
	initialize()
## 初始化
func initialize():
	a_star.region = get_used_rect()
	a_star.cell_size = tile_set.tile_size
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	update_grid_data_dict()
## 更新网格数据字典
func update_grid_data_dict():
	var used_cells := get_used_cells()
	grid_data_dict.clear()
	for cell in used_cells:
		grid_data_dict[cell] = WorldGrid.new()
		grid_data_dict[cell].grid_position = cell
		# 获取目标地块自定义数据
		var tile_data = get_cell_tile_data(cell)
		grid_data_dict[cell].name = tile_data.get_custom_data("name")
		grid_data_dict[cell].type = tile_data.get_custom_data("type")
## 更改网格数据字典
func change_grid_data(cell:Vector2i):
	if cell in grid_data_dict:
		var tile_data = get_cell_tile_data(cell)
		grid_data_dict[cell].grid_position = cell
		grid_data_dict[cell].type = tile_data.get_custom_data("type")
		grid_data_dict[cell].name = tile_data.get_custom_data("name")
	else:
		grid_data_dict[cell] = WorldGrid.new()
		var tile_data = get_cell_tile_data(cell)
		grid_data_dict[cell].grid_position = cell
		grid_data_dict[cell].type = tile_data.get_custom_data("type")
		grid_data_dict[cell].name = tile_data.get_custom_data("name")
## 绘制指定地块地形
func set_grid(cell:Vector2i,source_id:int,atlas_coords:Vector2i):
	set_cell(cell,source_id,atlas_coords)
	change_grid_data(cell)
	
# 生成随机地图
func generate_random_map():
	print("[DataLayer] 开始生成随机地图")
	clear()  # 清除现有地图
	Noise1.seed = randi()
	# Noise2.seed = randi()
	#Noise1.frequency = 0.005
	## frequency值越大越平缓 越小越尖锐
	Noise1.frequency = 0.1
	# Noise2.frequency = 0.01
	var width = 20
	var height = 20
	for x in range(width):
		for y in range(height):
			var noiseValue = Noise1.get_noise_2d(x, y)
			var random = getRandom(noiseValue)
			#set_cell( 绘制坐标_grid_position,图集ID_TileSetID ,图集坐标_ )
			set_cell(Vector2i(x, y), 0, Vector2i(random,0))
	print("[DataLayer] 随机地图生成完成，图块数量: ", get_used_cells().size())


#工具
#返回 0 1 2，0的概率很低
func getRandom(noiseValue)->int:
	# 将噪声值从[-1,1]映射到[0,1]
	var normalized_value = (noiseValue + 1) / 2.0
	
	# 使用阈值来控制0出现的概率
	# 当normalized_value < 0.1时返回0（10%概率）
	# 当normalized_value < 0.6时返回1（50%概率）  
	# 其他情况返回2（40%概率）
	if normalized_value < 0.1:
		return 1
	elif normalized_value < 0.6:
		return 1
	else:
		return 2

## 从序列化数据恢复地图
func deserialize(map_data:Dictionary):

	# 清除现有地图
	clear()
	
	# 恢复地块数据
	if map_data.has("tile_data"):
		var tile_data_array = map_data["tile_data"]
		
		for cell_data in tile_data_array:
			# 解析数组格式的地块数据
			# cell_data [source_id, atlas_coords_x, atlas_coords_y, alternative_tile, grid_position_x, grid_position_y]
			if cell_data is Array and cell_data.size() >= 6:
				var source_id = cell_data[0]  # 图集ID
				var atlas_coords_x = cell_data[1]  # 图集坐标X
				var atlas_coords_y = cell_data[2]  # 图集坐标Y
				var alternative_tile = cell_data[3]  # 替代图块
				var grid_position_x = cell_data[4]  # 网格位置X
				var grid_position_y = cell_data[5]  # 网格位置Y
				
				var atlas_coords = Vector2i(atlas_coords_x, atlas_coords_y)
				var grid_position = Vector2i(grid_position_x, grid_position_y)
				
				# 设置图块
				set_cell(grid_position, source_id, atlas_coords, alternative_tile)
			else:
				push_warning("地块数据格式不正确: ", cell_data)
		
		print("[DataLayer] 世界地图地块恢复完成，恢复地块数量: ", tile_data_array.size())
	
	# 恢复网格数据
	update_grid_data_dict()
	
	# 重新初始化A*寻路系统
	initialize()
	
	return true
## 序列化地图数据
func serialize() -> Dictionary:
	var map_data = {}
	
	# 收集所有使用的地块信息	
	var tile_data_dict : Array
	var used_cells:Array[Vector2i] = get_used_cells()
	
	for cell:Vector2i in used_cells:
		# var cell_data = {}
		var cell_data : Array = []
		#				0			1				2				3				4				5
		# cell_data [source_id,atlas_coords_x,atlas_coords_y,alternative_tile,grid_position_x,grid_position_y]
		# 获取图集ID（源ID）
		var source_id : int= get_cell_source_id(cell)
		cell_data.append(source_id)
		
		# 获取图集坐标
		var atlas_coords = get_cell_atlas_coords(cell)
		if atlas_coords != Vector2i(-1, -1):  # -1表示没有图块
			cell_data.append(atlas_coords.x)
			cell_data.append(atlas_coords.y)
		
		# 获取替代图块（如果有）
		var alternative_tile = get_cell_alternative_tile(cell)
		cell_data.append(alternative_tile)
		
		# 存储grid_position坐标
		cell_data.append(cell.x)
		cell_data.append(cell.y)
		
		# 将单元格数据存储到字典中，使用字符串格式的坐标作为键
		var cell_key = "%d,%d" % [cell.x, cell.y]
		# tile_data_dict[cell_key] = cell_data
		tile_data_dict.append(cell_data)
		
	# 存储地图尺寸信息
	map_data["map_width"] = get_used_rect().size.x
	map_data["map_height"] = get_used_rect().size.y
	
	# 存储所有地块数据
	map_data["tile_data"] = tile_data_dict
	
	
	print("[data_layer] 世界地图数据收集完成，地块数量: ", tile_data_dict.size())
	return map_data
