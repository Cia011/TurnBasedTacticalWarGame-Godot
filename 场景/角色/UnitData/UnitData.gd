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


# ---- 存档序列化 ----

func serialize() -> Dictionary:
	var buff_list: Array = []
	for buff in buff_manager.get_active_buffs():
		var buff_data := {
			"class": buff.get_class(),
			"id": buff.id,
			"name": buff.name,
			"duration": buff.duration,
			"max_stacks": buff.max_stacks,
			"current_stacks": buff.current_stacks,
		}
		if buff is ModifierBuff:
			var modifiers: Array = []
			for entry in buff.modifiers:
				modifiers.append({
					"stat": entry.stat,
					"flat": entry.flat,
					"mult": entry.mult,
				})
			buff_data["modifiers"] = modifiers
		buff_list.append(buff_data)
	return {
		"character_id": character_id,
		"character_name": character_name,
		"stats": get_states(),
		"flat_bonuses": data_manager.flat_bonuses.duplicate(),
		"final_bonuses": data_manager.final_bonuses.duplicate(),
		"buffs": buff_list,
	}


func deserialize(data: Dictionary) -> void:
	character_id = data.get("character_id", character_id)
	character_name = data.get("character_name", character_name)
	var stats: Dictionary = data.get("stats", {})
	level = int(stats.get("level", level))
	defense = int(stats.get("defense", defense))
	agility = int(stats.get("agility", agility))
	strength = int(stats.get("strength", strength))
	constitution = int(stats.get("constitution", constitution))
	intelligence = int(stats.get("intelligence", intelligence))
	action_points = int(stats.get("action_points", action_points))
	max_health = int(stats.get("max_health", max_health))
	current_health = int(stats.get("current_health", current_health))

	for stat in data.get("flat_bonuses", {}):
		var amount := int(data["flat_bonuses"][stat])
		if amount != 0:
			data_manager.add_flat_bonus(stat, amount)
	for stat in data.get("final_bonuses", {}):
		var amount := int(data["final_bonuses"][stat])
		if amount != 0:
			data_manager.add_final_bonus(stat, amount)

	buff_manager.clear_all_buffs()
	for buff_data in data.get("buffs", []):
		var buff := _create_buff_from_data(buff_data)
		if buff:
			buff_manager.add_buff(buff)


func _create_buff_from_data(data: Dictionary) -> BaseBuff:
	var buff: BaseBuff
	match data.get("class", ""):
		"ModifierBuff":
			var modifier_buff := ModifierBuff.new()
			for entry_data in data.get("modifiers", []):
				var entry := ModifierBuff.StatModifierEntry.new(
					entry_data.get("stat", ""),
					int(entry_data.get("flat", 0)),
					float(entry_data.get("mult", 1.0))
				)
				modifier_buff.modifiers.append(entry)
			buff = modifier_buff
		"AttackBuff":
			buff = AttackBuff.new()
		_:
			return null
	buff.id = data.get("id", buff.id)
	buff.name = data.get("name", buff.name)
	buff.duration = int(data.get("duration", -1))
	buff.max_stacks = int(data.get("max_stacks", 1))
	buff.current_stacks = int(data.get("current_stacks", 1))
	return buff


# ---- 装备连接（与 GBIS 装备槽联动） ----

## 返回该角色某个装备槽的完整槽名，例如 "{角色id}_主手"
func get_equipment_slot_name(slot_key: String) -> String:
	return "%s_%s" % [character_id, slot_key]


## 获取某个槽位上已装备的物品
func get_equipped_item(slot_key: String) -> BaseEquipmentItemData:
	var slot := GBIS.equipment_slot_service.get_slot(get_equipment_slot_name(slot_key))
	if slot and slot.equipped_item is BaseEquipmentItemData:
		return slot.equipped_item as BaseEquipmentItemData
	return null


## 把装备穿到指定槽位，成功后属性会写入 DataManager
func equip_item(item: BaseEquipmentItemData, slot_key: String) -> bool:
	if item == null or slot_key.is_empty():
		return false
	var slot_name := get_equipment_slot_name(slot_key)
	if not GBIS.equipment_slot_service.regist_slot(slot_name, [item.type]):
		return false
	return GBIS.equipment_slot_service.equip_to(slot_name, item)


## 脱下指定槽位的装备，优先放回已打开的背包，否则放回队伍背包
func unequip_item(slot_key: String) -> BaseEquipmentItemData:
	var slot_name := get_equipment_slot_name(slot_key)
	var item := GBIS.equipment_slot_service.unequip(slot_name)
	if item != null:
		return item as BaseEquipmentItemData

	var slot := GBIS.equipment_slot_service.get_slot(slot_name)
	if slot and slot.equipped_item is BaseEquipmentItemData:
		item = slot.equipped_item as BaseEquipmentItemData
		slot.unequip()
		if GBIS.inventory_service.get_container("TeamInventory") != null:
			GBIS.inventory_service.add_item("TeamInventory", item)
		return item
	return null


## 装备加成统一写入 DataManager（add=true 穿上，add=false 脱下）
func apply_equipment_bonuses(bonuses: Dictionary, add: bool) -> void:
	for stat in bonuses:
		var amount := int(bonuses[stat])
		if add:
			data_manager.add_flat_bonus(stat, amount)
		else:
			data_manager.remove_flat_bonus(stat, amount)


## 汇总所有已装备物品的属性加成
func get_equipment_stat_bonuses() -> Dictionary:
	var result := {}
	for slot_key in ["主手", "副手", "盔甲", "头盔", "戒指", "项链", "道具"]:
		var item := get_equipped_item(slot_key)
		if item == null:
			continue
		for stat in item.stat_bonuses:
			result[stat] = result.get(stat, 0) + int(item.stat_bonuses[stat])
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
