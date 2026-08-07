@abstract
class_name BaseEvent extends Resource
@export var id: String ## 事件ID
@export var name: String ## 事件名称
@export var duration: int  # 持续回合数，-1表示永久
@export var description: String ## 事件描述

@export var	grid_position : Vector2i ## 事件发生的网格位置

## "battle" "town"
@export var type:String = "battle" ## 事件类型 战斗事件 城镇事件
@export var icon: Texture2D ## 事件图标
var event_icon_node : Node ## 事件图标节点
@export var is_emergency: bool = false ## 是否为紧急事件 紧急事件会立即触发 而不是弹出弹窗
@export var auto_resolve: bool = false ## 触发后是否自动移除（一次性事件）

# 事件触发时 弹出UI
func apply_effect() -> void:
	pass

## 是否为永久事件
func is_permanent() -> bool:
	return duration == -1

## 是否已经过期
func is_expired() -> bool:
	return duration == 0

## 回合推进：非永久事件持续时间减一
func tick_duration() -> void:
	if duration > 0:
		duration -= 1

## 序列化为字典，子类在调用 super 后追加自己的字段
func serialize() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"type": type,
		"duration": duration,
		"description": description,
		"grid_position": [grid_position.x, grid_position.y],
		"is_emergency": is_emergency,
		"auto_resolve": auto_resolve,
	}

## 从字典恢复基础字段
func deserialize(data: Dictionary) -> void:
	id = data.get("id", id)
	name = data.get("name", name)
	type = data.get("type", type)
	duration = data.get("duration", duration)
	description = data.get("description", description)
	grid_position = Vector2i(data["grid_position"][0], data["grid_position"][1])
	is_emergency = data.get("is_emergency", is_emergency)
	auto_resolve = data.get("auto_resolve", auto_resolve)

# 移除时的效果
func remove_effect() -> void:
	remove_event_icon()

func remove_event_icon():
	if event_icon_node:
		event_icon_node.queue_free()

# 每回合开始时的效果
func on_turn_start() -> void:
	pass

# 每回合结束时的效果
func on_turn_end() -> void:
	pass

# 触发时效果
func on_trigger():
	pass
