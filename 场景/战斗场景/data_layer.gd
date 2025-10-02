extends TileMapLayer

var a_star : AStarGrid2D
var grid_data_dict : Dictionary[Vector2i,BattleGrid]
func _ready() -> void:
	BattleGridManager.data_layer = self
	initialize()
	
	print(Dijkstra._build_grid(get_used_rect(),grid_data_dict))
	
func initialize():
	a_star = AStarGrid2D.new()
	a_star.region = get_used_rect()
	a_star.cell_size = tile_set.tile_size
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	var used_cells := get_used_cells()
	for cell in used_cells:
		grid_data_dict[cell] = BattleGrid.new()
		grid_data_dict[cell].grid_position = cell
