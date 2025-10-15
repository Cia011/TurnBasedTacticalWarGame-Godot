extends Node2D
@onready var data_layer: TileMapLayer = $DataLayer
@onready var dec_layer: TileMapLayer = $DecLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer


signal on_ready()

func _ready() -> void:
	WorldGridManager.virulize_layer = highlight_layer
	
	# 初始化事件容器
	WorldEventManager.event_container = $EventContainer

	var battle_event = BattleEvent.new()
	battle_event.name = "战斗事件"
	battle_event.description = "非常艰难"
	battle_event.icon = preload("res://素材/图标/战斗图标/战斗图标.png")
	battle_event.grid_position = Vector2i(1,1)
	WorldEventManager.register_event(battle_event) 
	
	var town_event = townEvent.new()
	town_event.name = "城镇"
	town_event.description = "城镇"
	town_event.icon = preload("res://素材/图标/战斗图标/战斗图标.png")
	town_event.grid_position = Vector2i(2,2)
	WorldEventManager.register_event(town_event)

	on_ready.emit()
	GameState.scenes_ready.emit(self.name)
