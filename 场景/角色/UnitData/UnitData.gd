extends Node
class_name UnitData

# 信号
signal stats_changed(new_stats: Dictionary)

# 基础属性
@export_category("基础属性")
@export var character_name: String = ""
@export var level: int = 1:
	set(value):
		level = value
		_sync_base_stat("level", value)
@export var defense: int = 5:
	set(value):
		defense = value
		_sync_base_stat("defense", value)
@export var agility: int = 5:
	set(value):
		agility = value
		_sync_base_stat("agility", value)
@export var strength: int = 5:
	set(value):
		strength = value
		_sync_base_stat("strength", value)
@export var constitution: int = 5:
	set(value):
		constitution = value
		_sync_base_stat("constitution", value)
@export var intelligence: int = 5:
	set(value):
		intelligence = value
		_sync_base_stat("intelligence", value)
@export var action_points: int = 5:
	set(value):
		action_points = value
		_sync_base_stat("action_points", value)
@export var max_health: int = 100:
	set(value):
		max_health = value
		_sync_base_stat("max_health", value)
@export var current_health: int = 100:
	set(value):
		current_health = value
		_sync_base_stat("current_health", value)

@export var character_background_story: String
var character_id: String

var buffs: Dictionary = {}  # id -> BaseBuff
var data_manager: DataManager
var buff_manager: BuffManager

var _is_initialized: bool = false


func _init() -> void:
	var time = Time.get_unix_time_from_system()
	var random_component = randi() % 10000
	character_id = str(int(time * 10000) + random_component)

	data_manager = DataManager.new()
	data_manager.initialize(get_states())
	# 转发 DataManager 的属性变化信号，让外部只需 connect UnitData
	data_manager.stat_changed.connect(_on_stat_changed)
	_is_initialized = true

	buff_manager = BuffManager.new(self)


func get_character_id() -> String:
	return character_id


# 同步基础属性到 DataManager（在编辑器 setter 中自动调用）
func _sync_base_stat(stat_name: String, value):
	if _is_initialized and data_manager:
		if data_manager.base_stats.has(stat_name):
			data_manager.base_stats[stat_name] = value
		data_manager.stat_changed.emit({stat_name: data_manager.get_stat(stat_name)})


# 接收到 DataManager 变化后广播给外部
func _on_stat_changed(new_stats: Dictionary):
	stats_changed.emit(new_stats)


# 视觉表现
@export var texture: Texture2D = preload("res://素材/角色/Sprite-0010.png")


func get_states() -> Dictionary:
	return {
		"level": level,
		"defense": defense,
		"agility": agility,
		"strength": strength,
		"constitution": constitution,
		"intelligence": intelligence,
		"action_points": action_points,
		"max_health": max_health,
		"current_health": current_health,
	}


func get_base_stats() -> Dictionary:
	return get_states()


# 获取最终属性（含装备和 buff 修正）
func get_final_stat(stat_name: String) -> int:
	return data_manager.get_stat(stat_name)


func get_all_final_stats() -> Dictionary:
	var result = {}
	for stat in get_base_stats():
		result[stat] = get_final_stat(stat)
	return result


# ---- Buff 委托 ----

func add_buff(buff: BaseBuff) -> bool:
	return buff_manager.add_buff(buff)


func remove_buff(buff_id: String) -> bool:
	return buff_manager.remove_buff(buff_id)


func on_turn_start():
	buff_manager.on_turn_start()


func on_turn_end():
	buff_manager.on_turn_end()
