extends BaseEquipmentItemData
## 道具（饰品/杂物槽）
class_name TrinketItemData

func _init() -> void:
	type = "道具"
	compatible_slots = ["道具"]
	stat_bonuses = {"action_points": 1}
