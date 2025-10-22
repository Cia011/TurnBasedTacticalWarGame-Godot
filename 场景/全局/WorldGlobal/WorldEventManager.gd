extends Node
var events:Dictionary[Vector2i,BaseEvent]

#在大地图上存放事件图标的一个节点
var event_container : Node


#使用 event内部连接的 UI界面
#const BATTLE_EVENT_UI = preload("res://场景/UI/世界场景UI/事件触发UI/战斗触发UI/battle_event_ui.tscn")

const EVENT_ICON = preload("res://场景/世界场景/event/event_icon/event_icon.tscn")
## 注册事件
func register_event(event:BaseEvent) -> void:
	events[event.grid_position] = event
	show_event_icon(event)
## 更新事件图标显示
func update_event_display(event:BaseEvent):
	show_event_icon(event)
## 显示事件图标
func show_event_icon(event:BaseEvent):
	var event_icon = EVENT_ICON.instantiate()
	event_container.add_child(event_icon)
	event_icon.set_up(event)
## 注销事件
func unregister_event(grid_position : Vector2i) -> void:
	events.erase(grid_position)
## 获取事件
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
## 序列化事件
func _serializ_event()->Array:
	var event_data = []
	for event:BaseEvent in events.values():
		event_data.append(event.serialize())
	return event_data
## 恢复事件
func _restore_event(event_data:Array):
	for event in events.values():
		event.remove_event_icon()
	events.clear()
	for data in event_data:
		create_event(data)

## 事件的创建也由事件管理器负责
## 创建事件 根据事件数据创建事件对象 并注册事件 最后返回事件对象
func create_event(event_data:Dictionary)->BaseEvent:
	## 判断事件类型 根据事件类型创建事件对象
	var event = create_event_by_type(event_data["type"])
	event.deserialize(event_data)
	register_event(event)
	return event

#根据事件类型创建事件对象 并返回事件对象
func create_event_by_type(event_type:String)->BaseEvent:
	match event_type:
		"town":
			return TownEvent.new()
		"battle":
			return BattleEvent.new()
	return null
