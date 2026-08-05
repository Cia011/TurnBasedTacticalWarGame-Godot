extends ItemData
## 物品基类（自定义扩展层）
## 所有游戏物品的基础：增加价格、描述、重量，并接入队伍钱包买卖逻辑。
## 注意：可堆叠/消耗品/装备请分别继承 BaseStackableItemData / BaseConsumableItemData / BaseEquipmentItemData。
class_name BaseItemData

## 购买价格（金币）
@export var price: int = 0
## 出售价格倍率（0.5 = 半价出售）
@export_range(0.0, 1.0, 0.05) var sell_ratio: float = 0.5
## 物品描述
@export_multiline var description: String = ""
## 物品重量
@export var weight: float = 1.0

## 出售价格
func get_sell_price() -> int:
	return max(1, int(price * sell_ratio))

## 是否能购买（钱包余额是否足够）
func can_buy() -> bool:
	return PartyWallet.can_afford(price)

## 购买时扣钱
func cost() -> void:
	PartyWallet.spend(price)

## 是否能出售（默认允许；任务物品可重写返回 false）
func can_sell() -> bool:
	return true

## 出售时加钱
func sold() -> void:
	PartyWallet.earn(get_sell_price())

## 描述辅助：拼接价格等信息
func get_display_info() -> String:
	var text := "%s\n类型：%s" % [item_name, type]
	if description:
		text += "\n%s" % description
	text += "\n价格：%d  出售：%d" % [price, get_sell_price()]
	return text
