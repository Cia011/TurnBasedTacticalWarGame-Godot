extends Node
var events:Dictionary[Vector2i,BaseEvent]

#在大地图上存放事件图标的一个节点
var event_container : Node


#使用 event内部连接的 UI界面
#const BATTLE_EVENT_UI = preload("res://场景/UI/世界场景UI/事件触发UI/战斗触发UI/battle_event_ui.tscn")

const battle_event = preload("res://场景/世界场景/event/BattleEvent.gd")

const EVENT_ICON = preload("res://场景/世界场景/event/event_icon/event_icon.tscn")

func register_event(event:BaseEvent) -> void:
	events[event.grid_position] = event
	show_event_icon(event)

func show_event_icon(event:BaseEvent):
	var event_icon = EVENT_ICON.instantiate()
	event_container.add_child(event_icon)
	event_icon.set_up(event)

func unregister_event(grid_position : Vector2i) -> void:
	events.erase(grid_position)

func update_event_display():
	pass

#开始展示事件UI
#事件触发,由WorldGrid的进入函数触发
func trigger_event(event:BaseEvent):
	print("触发事件"+str(event))
	if event.type == 1:#1为战斗事件,
		print("展示ui")
		#先弹出选择界面UI,在UI中决定是否进入战斗
		var battle_event_ui = event.BATTLE_EVENT_UI.instantiate()
		var world_ui = get_tree().current_scene.find_child("WorldUI")
		var ui = world_ui.find_child("UI")
		ui.add_child(battle_event_ui)
		battle_event_ui.set_up(event)




#
