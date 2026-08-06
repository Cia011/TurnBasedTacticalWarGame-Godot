extends EquipmentData
## 装备基类（武器/盔甲/头盔/戒指/项链/道具）
## - compatible_slots：可放入的槽位名（如 ["主手", "副手"]）
## - stat_bonuses：装备后通过 DataManager.add_flat_bonus 注入的属性
## 装备槽 slot_name 约定为 "{角色id}_{槽位名}"，用于反查装备归属角色。
class_name BaseEquipmentItemData

@export var price: int = 0
@export_range(0.0, 1.0, 0.05) var sell_ratio: float = 0.5
@export_multiline var description: String = ""
@export var weight: float = 1.0

## 可放入的槽位
@export var compatible_slots: Array[String] = []
## 属性加成：{"strength": 5, "defense": 3}
@export var stat_bonuses: Dictionary = {}

## 检测是否可以装备到指定槽位
func test_need(slot_name: String) -> bool:
	var sep_index := slot_name.rfind("_")
	var slot_key := slot_name
	if sep_index >= 0:
		slot_key = slot_name.substr(sep_index + 1)
	return compatible_slots.has(slot_key)

## 装备时给角色加属性
func equipped(slot_name: String) -> void:
	var unit := _get_owner_unit(slot_name)
	if unit == null:
		push_warning("[%s] 找不到装备归属角色：%s" % [item_name, slot_name])
		return
	unit.apply_equipment_bonuses(stat_bonuses, true)
	print("[%s] 装备到 %s，加成 %s" % [item_name, slot_name, stat_bonuses])

## 脱下时移除属性
func unequipped(slot_name: String) -> void:
	var unit := _get_owner_unit(slot_name)
	if unit == null:
		return
	unit.apply_equipment_bonuses(stat_bonuses, false)
	print("[%s] 从 %s 脱下" % [item_name, slot_name])

## 从槽位名解析角色
func _get_owner_unit(slot_name: String) -> UnitData:
	var sep_index := slot_name.rfind("_")
	if sep_index <= 0:
		return null
	var character_id := slot_name.substr(0, sep_index)
	return GameState.find_unit_data_by_id(character_id)

func get_sell_price() -> int:
	return max(1, int(price * sell_ratio))

func can_buy() -> bool:
	return PartyWallet.can_afford(price)

func cost() -> void:
	PartyWallet.spend(price)

func can_sell() -> bool:
	return true

func sold() -> void:
	PartyWallet.earn(get_sell_price())

func get_display_info() -> String:
	var text := "%s\n类型：%s" % [item_name, type]
	if not stat_bonuses.is_empty():
		var parts: Array[String] = []
		for stat in stat_bonuses:
			parts.append("%s +%s" % [stat, stat_bonuses[stat]])
		text += "\n属性：%s" % "  ".join(parts)
	if description:
		text += "\n%s" % description
	text += "\n价格：%d  出售：%d" % [price, get_sell_price()]
	return text
