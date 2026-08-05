extends TileMapLayer

var a_star : AStarGrid2D
var grid_data_dict : Dictionary[Vector2i,BattleGrid]

@export var data_layer : TileMapLayer
@export var dec_layer : TileMapLayer
@export var highlight_layer : TileMapLayer

func _ready() -> void:
	initialize()
	Initialize_BattleGridManager(data_layer,dec_layer,highlight_layer)
	#print(Dijkstra._build_grid(get_used_rect(),grid_data_dict))
	
func initialize():
	a_star = AStarGrid2D.new()
	a_star.region = get_used_rect()
	a_star.cell_size = data_layer.tile_set.tile_size
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.update()
	
	var used_cells := data_layer.get_used_cells()
	for cell in used_cells:
		grid_data_dict[cell] = BattleGrid.new()
		grid_data_dict[cell].grid_position = cell
	print("[MainTileMap] used_cells is")
	print(used_cells)
func Initialize_BattleGridManager(data_layer : TileMapLayer,dec_layer : TileMapLayer,highlight_layer : TileMapLayer):
	BattleGridManager.MainTileMap = self
	BattleGridManager.highlight_layer = highlight_layer
	BattleGridManager.data_layer = data_layer
