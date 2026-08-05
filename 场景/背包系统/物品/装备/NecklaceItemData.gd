extends BaseEquipmentItemData
## 项链
class_name NecklaceItemData

func _init() -> void:
	type = "项链"
	compatible_slots = ["项链"]
	stat_bonuses = {"intelligence": 1}
