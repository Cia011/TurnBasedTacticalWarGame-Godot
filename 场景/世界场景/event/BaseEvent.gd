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
# 应用时的效果
# 事件触发函数
# 事件触发时 弹出UI
func apply_effect() -> void:
	pass

# 移除时的效果
func remove_effect() -> void:
	#pass
	#移除图标
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

func serialize() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"duration": duration,
		"description": description,
		"grid_position": grid_position,
		"type": type,
		"icon_path": icon.resource_path if icon else "",
		"is_emergency": is_emergency,
	}
func deserialize(data: Dictionary) -> void:
	id = data.get("id", id)
	name = data.get("name", name)
	duration = data.get("duration", duration)
	description = data.get("description", description)
	grid_position = ToolBox.string_to_vector2i(data.get("grid_position", grid_position))
	type = data.get("type", type)
	icon = load(data.get("icon_path", "")) 
	# print("资源路径存在吗?",ResourceLoader.exists(data.get("icon_path", "")))
	# if data.get("icon_path", "") else null
	is_emergency = data.get("is_emergency", is_emergency)
