extends StackableData
## 可堆叠物品基类（商品、矿石、材料等）
## 继承 GBIS StackableData，保留堆叠显示；加入价格/描述/买卖逻辑。
class_name BaseStackableItemData

@export var price: int = 0
@export_range(0.0, 1.0, 0.05) var sell_ratio: float = 0.5
@export_multiline var description: String = ""
@export var weight: float = 1.0

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
