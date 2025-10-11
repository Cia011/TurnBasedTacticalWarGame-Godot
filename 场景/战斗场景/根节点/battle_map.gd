extends Node2D
@onready var data_layer: TileMapLayer = $DataLayer
@onready var dec_layer: TileMapLayer = $DecLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer

@onready var team_position_1: Node2D = $TeamPosition1
@onready var team_position_2: Node2D = $TeamPosition2
class PositionAndID extends RefCounted:
	var position: Vector2i
	var id: int

	func _init(p: Vector2i, i: int):
		position = p
		id = i
var team_positions_0 : Array[PositionAndID] #敌
var team_positions_1 : Array[PositionAndID] #友

@onready var units: Node = $Units
const UNIT = preload("res://场景/角色/unit.tscn")

func _ready() -> void:
	#BattleGridManager.data_layer = data_layer
	BattleGridManager.virulize_layer = highlight_layer
	GameState.is_battleing = true
	
	var used_cells := dec_layer.get_used_cells()
	for cell in used_cells:
		
		var data = dec_layer.get_cell_tile_data(cell)
		var team : int= data.get_custom_data("team")
		if team == 0:
			team_positions_0.append(PositionAndID.new(cell,0))
		elif team == 1:
			team_positions_1.append(PositionAndID.new(cell,0))
	#初始化时根据GameState内的角色信息创建角色
	#初始化友方队伍
	for unit_data:UnitData in GameState.player_characters:
		var unit = UNIT.instantiate()
		
		#设置角色生成网格位置
		
		#var team1_position:Vector2i = BattleGridManager.get_grid_position(team_position_1.position)
		#var grid_position:Vector2i = BattleGridManager.BFS_find_first_not_occupied_gird(team1_position)
		#
		var grid_position:Vector2i
		for i in team_positions_1.size():
			if team_positions_1[i].id == 0:
				team_positions_1[i].id = 1
				grid_position = team_positions_1[i].position
				break
		#unit.position =  BattleGridManager.get_world_position(team1_position)

		unit.set_up(unit_data,grid_position)
		unit.is_teammate = true
		units.add_child(unit)
	#初始化敌方队伍
	for unit_data:UnitData in GameState.enemy_characters:
		var unit = UNIT.instantiate()
		var grid_position:Vector2i
		for i in team_positions_0.size():
			if team_positions_0[i].id == 0:
				team_positions_0[i].id = 1
				grid_position = team_positions_0[i].position
				break
		#unit.position =  BattleGridManager.get_world_position(team1_position)

		unit.set_up(unit_data,grid_position)
		unit.is_teammate = false
		units.add_child(unit)
	#初始化回合控制器
	BattleTurnManager.set_up()
	
