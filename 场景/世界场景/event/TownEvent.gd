extends BaseEvent
class_name townEvent

const TOWN_SCENE_UI = preload("res://场景/UI/世界场景UI/TownSceneUI/TownSceneUI.tscn")

func apply_effect() -> void:
	print("触发事件"+str(name))

	var UI = UiManager.get_ui("UI")
	var town_event_ui = TOWN_SCENE_UI.instantiate()
	UI.add_child(town_event_ui)
