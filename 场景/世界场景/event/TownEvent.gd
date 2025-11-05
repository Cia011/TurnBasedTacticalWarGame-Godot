class_name TownEvent extends BaseEvent

const TOWN_SCENE_UI = preload("res://场景/UI/世界场景UI/TownSceneUI/TownSceneUI.tscn")

func _init():
	type = "town"

func apply_effect() -> void:
	print("触发事件"+str(name))

	var UI = UiManager.get_ui("UI")
	var town_event_ui = TOWN_SCENE_UI.instantiate()
	UI.add_child(town_event_ui)

func deserialize(data:Dictionary)->void:
	super.deserialize(data)
	# 事件触发后，将事件触发点的网格设置为城镇地块
	WorldGridManager.set_grid(grid_position,0,Vector2i(0,0))
	
