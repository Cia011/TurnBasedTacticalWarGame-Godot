extends Node
## 游戏物品数据库（自动加载：GameItemDatabase）
## 集中定义示例物品与商店货物，方便扩展：新增物品就在这里创建并加入商店/初始背包。

const ICON_SWORD := "res://素材/图标/iton/剑.png"
const ICON_SLOT := "res://素材/图标/slot/slot.png"
const ICON_HELMET := "res://素材/图标/slot/头盔slot.png"
const ICON_ARMOR := "res://素材/图标/slot/盔甲slot.png"
const ICON_SHIELD := "res://素材/图标/slot/盾牌slot.png"
const ICON_RING := "res://素材/图标/slot/戒指slot.png"
const ICON_NECKLACE := "res://素材/图标/slot/项链slot.png"
const ICON_BELT := "res://素材/图标/slot/腰带slot.png"

const TEAM_INVENTORY := "TeamInventory"

func _ready() -> void:
	# 保证队伍背包容器存在
	GBIS.inventory_service.regist(TEAM_INVENTORY, 8, 5, false, ["ANY"])
	_build_shops()
	_seed_inventory()

## 示例武器
func make_iron_sword() -> WeaponItemData:
	var item := WeaponItemData.new()
	item.item_name = "铁剑"
	item.icon = load(ICON_SWORD)
	item.price = 120
	item.weight = 2.5
	item.description = "普通的铁制长剑，攻击稳定。"
	item.stat_bonuses = {"strength": 3}
	return item

func make_iron_shield() -> WeaponItemData:
	var item := WeaponItemData.new()
	item.item_name = "铁盾"
	item.icon = load(ICON_SHIELD)
	item.price = 90
	item.weight = 3.0
	item.description = "坚固的铁盾，能有效抵挡攻击。"
	item.stat_bonuses = {"defense": 2}
	return item

func make_leather_armor() -> ArmorItemData:
	var item := ArmorItemData.new()
	item.item_name = "皮甲"
	item.icon = load(ICON_ARMOR)
	item.price = 150
	item.weight = 4.0
	item.description = "轻便的皮革护甲。"
	item.stat_bonuses = {"defense": 2, "max_health": 5}
	return item

func make_iron_armor() -> ArmorItemData:
	var item := ArmorItemData.new()
	item.item_name = "铁甲"
	item.icon = load(ICON_ARMOR)
	item.price = 260
	item.weight = 8.0
	item.description = "厚重的铁制板甲，防御极高。"
	item.stat_bonuses = {"defense": 4, "max_health": 10}
	return item

func make_iron_helmet() -> HelmetItemData:
	var item := HelmetItemData.new()
	item.item_name = "铁盔"
	item.icon = load(ICON_HELMET)
	item.price = 80
	item.weight = 2.0
	item.description = "保护头部的铁盔。"
	item.stat_bonuses = {"defense": 2}
	return item

func make_silver_ring() -> RingItemData:
	var item := RingItemData.new()
	item.item_name = "银戒指"
	item.icon = load(ICON_RING)
	item.price = 200
	item.weight = 0.1
	item.description = "蕴含敏捷之力的银戒指。"
	item.stat_bonuses = {"agility": 2}
	return item

func make_pendant() -> NecklaceItemData:
	var item := NecklaceItemData.new()
	item.item_name = "智慧吊坠"
	item.icon = load(ICON_NECKLACE)
	item.price = 180
	item.weight = 0.2
	item.description = "提升魔法感知的吊坠。"
	item.stat_bonuses = {"intelligence": 2}
	return item

func make_war_belt() -> TrinketItemData:
	var item := TrinketItemData.new()
	item.item_name = "行军腰带"
	item.icon = load(ICON_BELT)
	item.price = 60
	item.weight = 0.5
	item.description = "多挂几个口袋的腰带，行动更灵活。"
	item.stat_bonuses = {"action_points": 1}
	return item

## 示例食物
func make_bread() -> FoodItemData:
	var item := FoodItemData.new()
	item.item_name = "面包"
	item.type = "食物"
	item.icon = load(ICON_SLOT)
	item.price = 8
	item.weight = 0.3
	item.stack_size = 10
	item.current_amount = 5
	item.heal_amount = 10
	item.description = "补充体力的硬面包，回复 10 点生命。"
	return item

func make_dried_meat() -> FoodItemData:
	var item := FoodItemData.new()
	item.item_name = "肉干"
	item.type = "食物"
	item.icon = load(ICON_SLOT)
	item.price = 15
	item.weight = 0.4
	item.stack_size = 10
	item.current_amount = 5
	item.heal_amount = 20
	item.description = "咸香的肉干，回复 20 点生命。"
	return item

func make_health_potion() -> PotionItemData:
	var item := PotionItemData.new()
	item.item_name = "生命药水"
	item.type = "消耗品"
	item.icon = load(ICON_SLOT)
	item.price = 30
	item.weight = 0.3
	item.stack_size = 10
	item.current_amount = 3
	item.heal_amount = 25
	item.description = "清澈的红色药水，回复 25 点生命。"
	return item

## 示例商品
func make_cloth() -> TradeGoodsItemData:
	var item := TradeGoodsItemData.new()
	item.item_name = "布料"
	item.type = "商品"
	item.icon = load(ICON_SLOT)
	item.price = 20
	item.weight = 0.5
	item.stack_size = 20
	item.current_amount = 1
	item.description = "常见的布料，可以在城镇出售。"
	return item

func make_herb() -> TradeGoodsItemData:
	var item := TradeGoodsItemData.new()
	item.item_name = "草药"
	item.type = "商品"
	item.icon = load(ICON_SLOT)
	item.price = 12
	item.weight = 0.2
	item.stack_size = 20
	item.current_amount = 1
	item.description = "可用于炼金的草药。"
	return item

func _build_shops() -> void:
	ShopManager.register_shop("杂货铺", [
		make_bread(),
		make_dried_meat(),
		make_health_potion(),
		make_cloth(),
		make_herb(),
		make_war_belt(),
	], 6, 4)

	ShopManager.register_shop("武器店", [
		make_iron_sword(),
		make_iron_shield(),
		make_iron_sword(),
	], 4, 3)

	ShopManager.register_shop("防具店", [
		make_leather_armor(),
		make_iron_armor(),
		make_iron_helmet(),
		make_war_belt(),
	], 5, 3)

	ShopManager.register_shop("饰品店", [
		make_silver_ring(),
		make_pendant(),
		make_silver_ring(),
		make_pendant(),
	], 4, 2)

func _seed_inventory() -> void:
	# 初始背包给一些补给和商品
	GBIS.add_item(TEAM_INVENTORY, make_bread())
	GBIS.add_item(TEAM_INVENTORY, make_dried_meat())
	GBIS.add_item(TEAM_INVENTORY, make_health_potion())
	GBIS.add_item(TEAM_INVENTORY, make_cloth())
	GBIS.add_item(TEAM_INVENTORY, make_herb())
	GBIS.add_item(TEAM_INVENTORY, make_iron_sword())
	GBIS.add_item(TEAM_INVENTORY, make_iron_shield())
	GBIS.add_item(TEAM_INVENTORY, make_leather_armor())
	GBIS.add_item(TEAM_INVENTORY, make_iron_helmet())
	GBIS.add_item(TEAM_INVENTORY, make_silver_ring())
	GBIS.add_item(TEAM_INVENTORY, make_pendant())
	GBIS.add_item(TEAM_INVENTORY, make_war_belt())
