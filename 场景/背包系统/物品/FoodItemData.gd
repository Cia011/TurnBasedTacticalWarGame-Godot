extends BaseConsumableItemData
## 食物类物品（回复生命/饱食度等）
## 使用后回复当前选中角色（InventoryContext.selected_unit_data）的生命值。
class_name FoodItemData

## 回复生命值
@export var heal_amount: int = 10

func _consume_effect() -> bool:
	return _heal_target(heal_amount)
