extends BaseEquipmentItemData
## 盔甲
class_name ArmorItemData

func _init() -> void:
	type = "盔甲"
	compatible_slots = ["盔甲"]
	stat_bonuses = {"defense": 3, "max_health": 10}
