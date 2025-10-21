extends Resource
class_name BaseEvent
@export var id: String
@export var name: String
@export var duration: int  # 持续回合数，-1表示永久
@export var description: String

@export var	grid_position : Vector2i

#1:战斗/
@export var type:int = 1
@export var icon: Texture2D
var event_icon_node : Node
@export var is_emergency: bool = false
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
