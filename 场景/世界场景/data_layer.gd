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
	generate_random_map()
	initialize()

func initialize():
	a_star.region = get_used_rect()
	a_star.cell_size = tile_set.tile_size
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	update_grid_data_dict()

func update_grid_data_dict():
	var used_cells := get_used_cells()
	grid_data_dict.clear()
	for cell in used_cells:
		grid_data_dict[cell] = WorldGrid.new()
		grid_data_dict[cell].grid_position = cell
# 生成随机地图
func generate_random_map():
	print("[DataLayer] 开始生成随机地图")
	clear()  # 清除现有地图
	Noise1.seed = randi()
	Noise2.seed = randi()
	Noise1.frequency = 0.005
	Noise2.frequency = 0.01
	var width = 20
	var height = 20
	for x in range(width):
		for y in range(height):
			var noiseValue = Noise1.get_noise_2d(x, y)
			var random = getRandom(noiseValue)
			#set_cell( 绘制坐标_grid_position,图集ID_TileSetID ,图集坐标_ )
			set_cell(Vector2i(x, y), 0, Vector2i(1,0))
	print("[DataLayer] 随机地图生成完成，图块数量: ", get_used_cells().size())


#工具
#返回 1 2 3 
func getRandom(noiseValue):
	var random:int = floor((noiseValue + 1)*2)
	if random == 4:
		random = 3
	return random
