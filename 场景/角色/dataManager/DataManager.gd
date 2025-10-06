extends Node
class_name DataManager

#signal unit_data_change(stat_name:String,new_value)
signal unit_data_change(new_stats:Dictionary)

var 基本数据: Dictionary = {}

var 基本加成: Dictionary = {}
var 修饰器: Dictionary = {}  # 存储所有修饰符

var 最终加成:Dictionary={}

var unit:Unit
func _ready() -> void:
	unit = owner
#func _init(unit:Unit) -> void:
	#unit = owner

func initialize(initial_stats: Dictionary):
	基本数据 = initial_stats.duplicate()#复制副本
	# 初始化加成和修饰符字典

	for stat in 基本数据:
		基本加成[stat] = 0
		最终加成[stat] = 0
		修饰器[stat] = []

# 获取最终属性值
func get_stat(stat_name: String) -> int:
	if not 基本数据.has(stat_name):
		return 0
	
	var base_value = 基本数据[stat_name] + 基本加成[stat_name]
	var final_value = float(base_value)
	
	
	var 加算修饰器 : Dictionary = {}
	var 乘算修饰器 :  Dictionary = {}
	# 应用所有修饰符
	for 修饰符 in 修饰器[stat_name]:
		加算修饰器.get_or_add(stat_name,0)
		加算修饰器[stat_name] += 修饰符.flat_bonus
		
		乘算修饰器.get_or_add(stat_name,1)
		乘算修饰器[stat_name] += 修饰符.multiplier
		
		final_value += 加算修饰器[stat_name]
		final_value = 乘算修饰器[stat_name] * final_value
		#final_value = 修饰符.apply(final_value)
	
	final_value += 最终加成[stat_name]
	
	return int(final_value)

# 添加基础加成（来自装备等）
func add_base_bonus(stat_name: String, amount: int):
	if 基本加成.has(stat_name):
		基本加成[stat_name] += amount
	unit_data_change.emit({stat_name:get_stat(stat_name)})

# 移除基础加成
func remove_base_bonus(stat_name: String, amount: int):
	if 基本加成.has(stat_name):
		基本加成[stat_name] -= amount
	unit_data_change.emit({stat_name:get_stat(stat_name)})

#最终加成---旨在处理受伤行为
func add_final_bonus(stat_name: String, amount: int):
	if 最终加成.has(stat_name):
		最终加成[stat_name] += amount
	unit_data_change.emit({stat_name:get_stat(stat_name)})

func remove_final_bonus(stat_name: String, amount: int):
	if 最终加成.has(stat_name):
		最终加成[stat_name] -= amount
	unit_data_change.emit({stat_name:get_stat(stat_name)})

# 添加修饰符（来自Buff等）
func add_modifier(stat_name: String, flat_bonus: int = 0, multiplier: float = 1.0):
	if not 修饰器.has(stat_name):
		修饰器[stat_name] = []
	
	var modifier = 修饰符类.new(flat_bonus, multiplier)
	修饰器[stat_name].append(modifier)
	unit_data_change.emit({stat_name:get_stat(stat_name)})
	
# 移除修饰符
func remove_modifier(stat_name: String, flat_bonus: int = 0, multiplier: float = 1.0):
	if 修饰器.has(stat_name):
		for i in range(修饰器[stat_name].size() - 1, -1, -1):
			var modifier = 修饰器[stat_name][i]
			if modifier.flat_bonus == flat_bonus and modifier.multiplier == multiplier:
				修饰器[stat_name].remove_at(i)
	unit_data_change.emit({stat_name:get_stat(stat_name)})

# 修饰符类
class 修饰符类:
	var flat_bonus: int
	var multiplier: float
	
	func _init(flat: int = 0, mult: float = 1.0):
		flat_bonus = flat
		multiplier = mult
	
	func apply(base_value: float) -> float:
		return (base_value + flat_bonus) * multiplier
