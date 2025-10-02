extends BaseEvent
class_name BattleEvent
#@export var battle_event_ui_scenes : PackedScene

const BATTLE_EVENT_UI = preload("res://场景/UI/世界场景UI/battle_event_ui.tscn")

func apply_effect() -> void:
	printt("apply_effect")
	WorldEventManager.trigger_event(self)
