
class_name BattleEvent extends BaseEvent
#@export var battle_event_ui_scenes : PackedScene

const BATTLE_EVENT_UI = preload("res://场景/UI/世界场景UI/事件触发UI/战斗触发UI/battle_event_ui.tscn")

func _init():
	type = "battle"

func apply_effect() -> void:
	printt("apply_effect")
	trigger_event()
	
func trigger_event():
	print("触发事件"+str(name))
	
	var battle_event_ui = BATTLE_EVENT_UI.instantiate()
	var UI = UiManager.get_ui("UI")
	UI.add_child(battle_event_ui)
	battle_event_ui.set_up(self)
