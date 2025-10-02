extends TileMapLayer

var a_star : AStarGrid2D
var grid_data_dict : Dictionary[Vector2i,WorldGrid]
func _ready() -> void:
	WorldGridManager.data_layer = self
	initialize()

func initialize():
	a_star = AStarGrid2D.new()
	a_star.region = get_used_rect()
	a_star.cell_size = tile_set.tile_size
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	var used_cells := get_used_cells()
	for cell in used_cells:
		grid_data_dict[cell] = WorldGrid.new()
		grid_data_dict[cell].grid_position = cell
