extends Node2D
@onready var data_layer: TileMapLayer = $DataLayer
@onready var dec_layer: TileMapLayer = $DecLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer

func _ready() -> void:
	WorldGridManager.virulize_layer = highlight_layer
	
	var battle_event = WorldEventManager.battle_event.new()
	battle_event.name = "战斗事件"
	battle_event.description = "非常艰难"
	WorldEventManager.register_event(Vector2i(1,1),battle_event) 
	
	
	#var battle_event_ui_scene = WorldEventManager.BATTLE_EVENT_UI.instantiate()
	#battle_event_ui_scene.set_up(battle_event)
	
