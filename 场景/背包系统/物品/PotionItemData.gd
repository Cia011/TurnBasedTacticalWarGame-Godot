extends BaseConsumableItemData
## 药水类物品（回复生命等）
## 与食物共用回复逻辑，方便后续扩展法力/解毒等药水。
class_name PotionItemData

## 回复生命值
@export var heal_amount: int = 25

func _consume_effect() -> bool:
	return _heal_target(heal_amount)
