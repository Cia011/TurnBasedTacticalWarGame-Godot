extends ConsumableData
## 消耗品基类（食物、药水等）
## 使用时机由 GBIS 右键触发；具体效果在子类 _consume_effect() 中实现。
class_name BaseConsumableItemData

@export var price: int = 0
@export_range(0.0, 1.0, 0.05) var sell_ratio: float = 0.5
@export_multiline var description: String = ""
@export var weight: float = 1.0

## 使用物品：调用子类效果后扣减数量
func consume() -> int:
	return 1 if _consume_effect() else 0

## 子类实现具体效果，返回是否真正消耗物品
func _consume_effect() -> bool:
	push_warning("[BaseConsumableItemData] %s 未实现 _consume_effect()" % item_name)
	return false

## 对当前选中角色回复生命；未选中时退回队伍第一个角色
func _heal_target(amount: int) -> bool:
	var target := InventoryContext.selected_unit_data
	if target == null:
		target = GameState.player_characters[0] if not GameState.player_characters.is_empty() else null
	if target == null:
		push_warning("没有可使用的角色")
		return false
	var current := target.get_final_stat("current_health")
	var max_health := target.get_final_stat("max_health")
	var healed := clampi(current + amount, 0, max_health) - current
	if healed <= 0:
		return false
	target.data_manager.add_final_bonus("current_health", healed)
	print("[%s] 使用 %s，回复 %d 生命" % [target.character_name, item_name, healed])
	return true

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
	var text := "%s\n类型：%s  数量：%d/%d" % [item_name, type, current_amount, stack_size]
	if description:
		text += "\n%s" % description
	text += "\n价格：%d  出售：%d" % [price, get_sell_price()]
	return text
