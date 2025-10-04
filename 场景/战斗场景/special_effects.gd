extends Node
#容器节点,用来存放效果,弹幕弹窗,技能特效
func _ready() -> void:
	PopManager.special_effects_node = self
