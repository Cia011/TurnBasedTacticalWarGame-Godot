extends Node
class_name UnitData
# 信号
signal stats_changed(new_stats: Dictionary)
func _on_stats_changed(new_stats: Dictionary):
	stats_changed.emit(new_stats)
# 基础属性
@export_category("基础属性")
@export var character_name: String = ""	#名称
@export var level: int = 1:#等级
	set(value):
		level = value
		_sync_base_stat("level", value)
#@export var defense: int = 5			#防御-细分物抗魔抗 未实现
@export var defense: int = 5:
	set(value):
		defense = value
		_sync_base_stat("defense", value)
#@export var agility : int = 5		#敏捷-影响回合,闪避
@export var agility: int = 5:
	set(value):
		agility = value
		_sync_base_stat("agility", value)
#@export var strength:int = 5			#力量-影响攻击伤害
@export var strength: int = 5:
	set(value):
		strength = value
		_sync_base_stat("strength", value)
#@export var constitution:int = 5		#体质-影响负重,生命值
@export var constitution: int = 5:
	set(value):
		constitution = value
		_sync_base_stat("constitution", value)
#@export var intelligence:int = 5		#智力-影响蓝量,魔法攻击伤害
@export var intelligence: int = 5:
	set(value):
		intelligence = value
		_sync_base_stat("intelligence", value)

#@export var action_points : int = 5		#行动力,回合可使用行动力数量
@export var action_points: int = 5:
	set(value):
		action_points = value
		_sync_base_stat("action_points", value)

#@export var max_health: int = 100		#最大生命值
@export var max_health: int = 100:
	set(value):
		max_health = value
		_sync_base_stat("max_health", value)
#@export var current_health: int = 100	#当前生命值
@export var current_health: int = 100:
	set(value):
		current_health = value
		_sync_base_stat("current_health", value)

#
@export var character_background_story:String
var character_id : String
 #装备和物品
var equipments: BaseBackpack

var buffs: Dictionary = {}  # id -> BaseBuff

var data_manager : DataManager
var buff_manager: BuffManager

var equipments_types : Array[String] = [	"武器","头盔","护甲","靴子","武器",
										"戒指","项链","腰带","手套","戒指"]

var _is_initialized :bool= false
func _init() -> void:
	var time = Time.get_unix_time_from_system()
	var random_component = randi() % 10000
	character_id = str(int(time*10000)+random_component)
	
	equipments = BaseBackpack.new()
	equipments.items.resize(10)
	
	equipments.item_change.connect(_on_equipment_change)
	
	data_manager = DataManager.new()
	data_manager.initialize(get_states())
	_is_initialized = true
	data_manager.unit_data_change.connect(_on_stats_changed)
	
	
	 # 创建 BuffManager
	buff_manager = BuffManager.new(self)

func add_equipment(item:BaseItem)->bool:
	for index in equipments_types.size():
		var type:String = equipments_types[index]
		if type == item.item_type:
			if equipments.get_item(index) == null:
				equipments.set_item(index,item)
				return true
	return false
# 同步基础属性到 DataManager
func _sync_base_stat(stat_name: String, value):
	if _is_initialized and data_manager:
		
		# 更新 DataManager 中的基础值
		if data_manager.基本数据.has(stat_name):
			data_manager.基本数据[stat_name] = value
		# 触发重新计算
		data_manager.unit_data_change.emit({stat_name: data_manager.get_stat(stat_name)})


## 视觉表现
@export var texture: Texture2D

func get_states() -> Dictionary:
	return {
		"character_name" : character_name,
		"level":level,
		"defense":defense,
		"agility":agility,
		"strength":strength,
		"constitution":constitution,
		"intelligence":intelligence,
		"action_points":action_points,
		"max_health":max_health,
		"current_health":current_health
	}
#不同名方法
func get_base_stats() -> Dictionary:
	return get_states()

func _on_equipment_change(indexs):
	# 重新计算装备加成
	_update_equipment_bonus()
	# 标记战斗属性需要更新（如果有战斗实例）
	stats_changed.emit()
func _update_equipment_bonus():
	# 清除之前的装备加成
	for stat in data_manager.基本加成:
		data_manager.基本加成[stat] = 0
	
	# 计算所有装备的加成
	for item in equipments.items:
		if item and item is BaseItem:
			_apply_equipment_bonus(item)
	
func _apply_equipment_bonus(item: BaseItem):
	# 假设BaseItem有get_properties方法返回属性加成
	var properties = item.get_properties()
	if properties == null:return
	for stat_name in properties:
		if data_manager.基本加成.has(stat_name):
			data_manager.基本加成[stat_name] += properties[stat_name]
# 获取最终属性（包含装备和buff）
func get_final_stat(stat_name: String) -> int:
	return data_manager.get_stat(stat_name)
func get_all_final_stats() -> Dictionary:
	var result = {}
	for stat in get_base_stats():
		result[stat] = get_final_stat(stat)
	return result
# Buff管理委托方法
func add_buff(buff: BaseBuff) -> bool:
	return buff_manager.add_buff(buff)
func remove_buff(buff_id: String) -> bool:
	return buff_manager.remove_buff(buff_id)
func on_turn_start():
	buff_manager.on_turn_start()
func on_turn_end():
	buff_manager.on_turn_end()
