extends BaseEquipmentItemData
## 头盔
class_name HelmetItemData

func _init() -> void:
	type = "头盔"
	compatible_slots = ["头盔"]
	stat_bonuses = {"defense": 1}
