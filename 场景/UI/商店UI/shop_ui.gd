extends Control
## 商店界面：展示商店货物（可购买）与队伍背包（可出售）。

const TEAM_INVENTORY := "TeamInventory"

@onready var shop_name_label: Label = $Center/Panel/Margin/VBox/Header/ShopNameLabel
@onready var money_label: Label = $Center/Panel/Margin/VBox/Header/MoneyLabel
@onready var close_button: Button = $Center/Panel/Margin/VBox/Header/CloseButton
@onready var shop_tabs: HBoxContainer = $Center/Panel/Margin/VBox/ShopTabs
@onready var shop_container: Control = $Center/Panel/Margin/VBox/Body/ShopColumn/ShopContainer
@onready var inv_container: Control = $Center/Panel/Margin/VBox/Body/InvColumn/InvContainer
@onready var item_info_panel: ItemInfoPanel = $Center/Panel/Margin/VBox/ItemInfoPanel
#@onready var shop_view: ShopView = $Center/Panel/Margin/VBox/Body/ShopColumn/ShopContainer/ShopView
#@onready var inv_view: InventoryView = $Center/Panel/Margin/VBox/Body/InvColumn/InvContainer/InventoryView


func _ready() -> void:
	PartyWallet.money_changed.connect(_on_money_changed)
	close_button.pressed.connect(ShopManager.close_shop)
	_build_shop_tabs()
	_on_money_changed(PartyWallet.money, PartyWallet.money)


func open_shop(shop_name: String, shop_def: Dictionary) -> void:
	shop_name_label.text = shop_name

	# 清空旧的商店/背包视图
	for child in shop_container.get_children():
		child.queue_free()
	for child in inv_container.get_children():
		child.queue_free()

	# 商店货物视图
	var shop_view := ShopView.new()
	shop_view.container_name = shop_name
	shop_view.container_columns = shop_def.get("columns", 6)
	shop_view.container_rows = shop_def.get("rows", 4)
	shop_view.base_size = 48
	var goods: Array[ItemData] = []
	for good in shop_def.get("goods", []):
		if good is ItemData:
			goods.append(good)
	shop_view.goods = goods
	shop_container.add_child(shop_view)

	# 队伍背包视图（用于出售）
	var inv_view := InventoryView.new()
	inv_view.container_name = TEAM_INVENTORY
	inv_view.container_columns = 8
	inv_view.container_rows = 4
	inv_view.base_size = 40
	inv_container.add_child(inv_view)


func _on_money_changed(_old_value: int, new_value: int) -> void:
	if money_label:
		money_label.text = "金币：%d" % new_value

## 为每个已注册的商店生成一个切换按钮，方便在多个商店间跳转
func _build_shop_tabs() -> void:
	for child in shop_tabs.get_children():
		child.queue_free()
	for shop_name in ShopManager.shop_defs:
		var button := Button.new()
		button.text = shop_name
		button.flat = true
		button.pressed.connect(ShopManager.open_shop.bind(shop_name))
		shop_tabs.add_child(button)
