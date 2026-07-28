class_name ModifierBuff extends BaseBuff
## 泛用属性修正 Buff —— 通过 modifiers 数组定义多个 stat 的 flat + mult 变化
## 用法:
##   var buff = ModifierBuff.new()
##   buff.id = "power_up"
##   buff.modifiers = [{stat = "strength", flat = 10}, {stat = "agility", mult = 1.5}]
##   buff.duration = 3
##   target.add_buff(buff)

var modifiers: Array[StatModifierEntry] = []

# 应用所有 modifier
func apply_effect() -> void:
	for entry in modifiers:
		target.data_manager.add_modifier(entry.stat, entry.flat, entry.mult)

# 移除所有 modifier
func remove_effect() -> void:
	for entry in modifiers:
		target.data_manager.remove_modifier(entry.stat, entry.flat, entry.mult)

# modifier 条目
class StatModifierEntry:
	var stat: String
	var flat: int
	var mult: float

	func _init(p_stat: String, p_flat: int = 0, p_mult: float = 1.0):
		stat = p_stat
		flat = p_flat
		mult = p_mult
