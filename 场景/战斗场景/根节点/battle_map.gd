extends Node2D
@onready var data_layer: TileMapLayer = $DataLayer
@onready var dec_layer: TileMapLayer = $DecLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer

@onready var team_position_1: Node2D = $TeamPosition1
@onready var team_position_2: Node2D = $TeamPosition2


@onready var units: Node = $Units
const UNIT = preload("res://场景/角色/unit.tscn")

func _ready() -> void:
	#BattleGridManager.data_layer = data_layer
	BattleGridManager.virulize_layer = highlight_layer
	
	
	#初始化时根据GameState内的角色信息创建角色
	#初始化友方队伍
	for unit_data:UnitData in GameState.player_characters:
		var unit = UNIT.instantiate()
		
		#设置角色生成网格位置
		
		var team1_position:Vector2i = BattleGridManager.get_grid_position(team_position_1.position)
		var grid_position:Vector2i = BattleGridManager.BFS_find_first_not_occupied_gird(team1_position)
		#unit.position =  BattleGridManager.get_world_position(team1_position)

		unit.set_up(unit_data,grid_position)
		unit.is_teammate = true
		units.add_child(unit)
		
	#初始化回合控制器
	BattleTurnManager.set_up()
	
