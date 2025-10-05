extends Node
var events:Dictionary[Vector2i,BaseEvent]

#在大地图上存放事件图标的一个节点
var event_container : Node


#使用 event内部连接的 UI界面
#const BATTLE_EVENT_UI = preload("res://场景/UI/世界场景UI/事件触发UI/战斗触发UI/battle_event_ui.tscn")

const EVENT_ICON = preload("res://场景/世界场景/event/event_icon/event_icon.tscn")

func register_event(event:BaseEvent) -> void:
	events[event.grid_position] = event
	show_event_icon(event)

func update_event_display(event:BaseEvent):
	show_event_icon(event)
func show_event_icon(event:BaseEvent):
	var event_icon = EVENT_ICON.instantiate()
	event_container.add_child(event_icon)
	event_icon.set_up(event)

func unregister_event(grid_position : Vector2i) -> void:
	events.erase(grid_position)

func get_grid_event(grid_position:Vector2i)->BaseEvent:
	if events.has(grid_position):
		return events[grid_position]
	return null
	
#事件触发,由WorldGrid的进入函数触发
func trigger_event(grid_position:Vector2i):
	if events.has(grid_position):
		#若是突发事件,直接触发
		if events[grid_position].is_emergency:
			events[grid_position].apply_effect()
