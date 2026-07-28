extends Node
class_name DataManager

## 属性数据管理器
## 三层架构：base_stats (基础) → flat_bonuses (装备) → modifiers (buff修饰)
## 最终值 = (base + flat) * mult_product + final_bonus

signal stat_changed(changed_stats: Dictionary)

var base_stats: Dictionary = {}      # 基础属性（等级、力量、敏捷等）
var flat_bonuses: Dictionary = {}    # 装备/被动提供的数值加成
var final_bonuses: Dictionary = {}   # 最终数值修正（如受伤扣血、临时光环）
var modifiers: Dictionary = {}       # 修饰符列表（buff 提供的 flat + multiplier）


func initialize(initial_stats: Dictionary):
	base_stats = initial_stats.duplicate()
	for stat in base_stats:
		flat_bonuses[stat] = 0
		final_bonuses[stat] = 0
		modifiers[stat] = []


# 获取最终属性值
func get_stat(stat_name: String) -> int:
	if not base_stats.has(stat_name):
		return 0
	var raw = base_stats.get(stat_name, 0)
	if raw is String:
		return 0

	# 基础值 + 装备 flat 加成
	var value = float(raw + flat_bonuses.get(stat_name, 0))

	# 汇总所有 modifier 的 flat 和 multiplier
	var total_flat: int = 0
	var total_mult: float = 1.0
	for mod in modifiers.get(stat_name, []):
		total_flat += mod.flat_bonus
		total_mult *= mod.multiplier

	# 先加 flat，再乘 multiplier 链
	value = (value + total_flat) * total_mult

	# 最终修正（受伤/治疗等即时效果）
	value += final_bonuses.get(stat_name, 0)

	return int(value)


# ---- 装备 / 被动 flat 加成 ----

func add_flat_bonus(stat_name: String, amount: int):
	if flat_bonuses.has(stat_name):
		flat_bonuses[stat_name] += amount
	stat_changed.emit({stat_name: get_stat(stat_name)})


func remove_flat_bonus(stat_name: String, amount: int):
	if flat_bonuses.has(stat_name):
		flat_bonuses[stat_name] -= amount
	stat_changed.emit({stat_name: get_stat(stat_name)})


# ---- 最终修正（即时生效，如扣血） ----

func add_final_bonus(stat_name: String, amount: int):
	if final_bonuses.has(stat_name):
		final_bonuses[stat_name] += amount
	stat_changed.emit({stat_name: get_stat(stat_name)})


func remove_final_bonus(stat_name: String, amount: int):
	if final_bonuses.has(stat_name):
		final_bonuses[stat_name] -= amount
	stat_changed.emit({stat_name: get_stat(stat_name)})


# ---- 修饰符（buff） ----

func add_modifier(stat_name: String, flat_bonus: int = 0, multiplier: float = 1.0):
	if not modifiers.has(stat_name):
		modifiers[stat_name] = []
	var mod = StatModifier.new(flat_bonus, multiplier)
	modifiers[stat_name].append(mod)
	stat_changed.emit({stat_name: get_stat(stat_name)})


func remove_modifier(stat_name: String, flat_bonus: int = 0, multiplier: float = 1.0):
	if modifiers.has(stat_name):
		var list = modifiers[stat_name]
		for i in range(list.size() - 1, -1, -1):
			if list[i].flat_bonus == flat_bonus and list[i].multiplier == multiplier:
				list.remove_at(i)
	stat_changed.emit({stat_name: get_stat(stat_name)})


# 修饰符数据结构
class StatModifier:
	var flat_bonus: int
	var multiplier: float

	func _init(flat: int = 0, mult: float = 1.0):
		flat_bonus = flat
		multiplier = mult

	func apply(base_value: float) -> float:
		return (base_value + flat_bonus) * multiplier
