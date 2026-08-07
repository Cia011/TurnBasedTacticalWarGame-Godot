extends Node
## 总事件管理器：统筹大地图上的所有事件。
## - 一个格子可以挂多个事件
## - 城镇为永久事件，战斗/探索事件按回合数消失
## - 负责事件的注册、触发、回合推进、图标显示和存档

signal turn_ticked

var events: Array[BaseEvent] = []
var events_by_grid: Dictionary = {}

## 在大地图上存放事件图标的节点
var event_container: Node

const EVENT_ICON := preload("res://场景/世界场景/event/event_icon/event_icon.tscn")


## 注册事件
func register_event(event: BaseEvent) -> void:
	if event == null or events.has(event):
		return
	events.append(event)
	if not events_by_grid.has(event.grid_position):
		events_by_grid[event.grid_position] = []
	events_by_grid[event.grid_position].append(event)
	show_event_icon(event)


## 注销事件
func unregister_event(event: BaseEvent) -> void:
	events.erase(event)
	if events_by_grid.has(event.grid_position):
		events_by_grid[event.grid_position].erase(event)
		if events_by_grid[event.grid_position].is_empty():
			events_by_grid.erase(event.grid_position)
	event.remove_event_icon()


## 获取指定格子上所有事件
func get_grid_events(grid_position: Vector2i) -> Array:
	var list: Array = events_by_grid.get(grid_position, [])
	return list


## 触发指定格子上的所有事件
func trigger_grid(grid_position: Vector2i) -> void:
	var grid_events: Array = get_grid_events(grid_position).duplicate()
	for event in grid_events:
		event.apply_effect()
		if event.auto_resolve:
			unregister_event(event)


## 回合推进：事件持续时间减一，触发回合钩子；同时刷新商店补货
func tick_turns() -> void:
	for event in events.duplicate():
		event.on_turn_start()
		event.on_turn_end()
		if not event.is_permanent():
			event.tick_duration()
			if event.is_expired():
				unregister_event(event)
	turn_ticked.emit()


## 显示事件图标（同一格多个事件时错开摆放）
func show_event_icon(event: BaseEvent) -> void:
	if event_container == null:
		return
	var event_icon := EVENT_ICON.instantiate()
	event_container.add_child(event_icon)
	event_icon.set_up(event)
	var index: int = events_by_grid.get(event.grid_position, []).find(event)
	event_icon.position += Vector2(index % 4, index / 4) * 8


## 根据事件类型创建事件对象
func create_event_by_type(event_type: String) -> BaseEvent:
	match event_type:
		"battle":
			return BattleEvent.new()
		"town":
			return TownEvent.new()
		"explore":
			return ExploreEvent.new()
	return null


## 根据存档数据创建并恢复事件
func create_event_from_data(data: Dictionary) -> BaseEvent:
	var event := create_event_by_type(data.get("type", "battle"))
	if event:
		event.deserialize(data)
	return event


## 序列化所有事件
func serialize() -> Dictionary:
	var event_list: Array = []
	for event in events:
		event_list.append(event.serialize())
	return {"events": event_list}


func get_save_data() -> Dictionary:
	return serialize()


## 从存档恢复所有事件
func deserialize(data: Dictionary) -> void:
	for event in events.duplicate():
		unregister_event(event)
	if data.has("events"):
		for event_data in data["events"]:
			var event := create_event_from_data(event_data)
			if event:
				register_event(event)


func apply_save_data(data: Dictionary) -> void:
	deserialize(data)
