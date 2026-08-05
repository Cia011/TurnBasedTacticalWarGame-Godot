extends BaseEquipmentItemData
## 戒指
class_name RingItemData

func _init() -> void:
	type = "戒指"
	compatible_slots = ["戒指"]
	stat_bonuses = {"agility": 1}
