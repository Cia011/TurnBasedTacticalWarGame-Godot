extends RefCounted
class_name BaseBuff

enum BuffType { BUFF, DEBUFF, NEUTRAL }

var id: String
var name: String
var icon: Texture2D
var type: BuffType
var duration: int  # 持续回合数，-1表示永久
var max_stacks: int = 1
var current_stacks: int = 1
var description: String

var source: Node  # Buff来源
var target: UnitData  # Buff目标

# 应用Buff时的效果
func apply_effect() -> void:
	pass

# 移除Buff时的效果
func remove_effect() -> void:
	pass

# 每回合开始时的效果
func on_turn_start() -> void:
	pass

# 每回合结束时的效果
func on_turn_end() -> void:
	if duration > 0:
		duration -= 1
	elif duration == 0:
		target.Buff系统.remove_buff(id)

# 被攻击时的效果
func on_attacked(damage: int, attacker: Unit) -> void:
	pass

# 攻击时的效果
func on_attack(damage: int, target: Unit) -> void:
	pass

# 移动时的效果
func on_move(distance: int) -> void:
	pass

# 是否可以叠加
func can_stack() -> bool:
	return max_stacks > 1

# 增加堆叠
func add_stack() -> bool:
	if can_stack() and current_stacks < max_stacks:
		current_stacks += 1
		return true
	return false
