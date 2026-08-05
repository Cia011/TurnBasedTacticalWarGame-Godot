extends BaseEquipmentItemData
## 武器（主手/副手通用）
class_name WeaponItemData

func _init() -> void:
	type = "武器"
	compatible_slots = ["主手", "副手"]
	stat_bonuses = {"strength": 2}
