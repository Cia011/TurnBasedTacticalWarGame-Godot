extends Node
## 商店管理组件（自动加载：ShopManager）
## 统一管理多个商店/城镇/野外商人：等级、商品、库存、资金、补货周期。
## 商店不是无限供应：物品有库存上限，收购玩家物品受资金限制。

signal shop_opened(shop_name: String)
signal shop_closed

const ShopUIScene := preload("res://场景/UI/商店UI/shop_ui.tscn")

## shop_name -> {goods, columns, rows, tier, funds, base_funds, stock_limits, restock_interval, restock_counter, sell_ratio}
var shop_defs: Dictionary = {}
var current_shop_name: String = ""
var team_inventory_name: String = "TeamInventory"

var _shop_layer: CanvasLayer
var _shop_ui: Control


func _ready() -> void:
	WorldEventManager.turn_ticked.connect(restock_all_shops)


## 注册一个商店。opts 支持 tier / funds / stock_limits / restock_interval / sell_ratio
func register_shop(
	shop_name: String,
	goods: Array,
	columns: int = 6,
	rows: int = 4,
	opts: Dictionary = {}
) -> void:
	var tier := int(opts.get("tier", 1))
	var base_funds := int(opts.get("funds", 200 * tier))
	var stock_limits: Dictionary = {}
	for good in goods:
		if good is ItemData:
			stock_limits[good.item_name] = stock_limits.get(good.item_name, 0) + 1
	shop_defs[shop_name] = {
		"goods": goods,
		"columns": columns,
		"rows": rows,
		"tier": tier,
		"funds": base_funds,
		"base_funds": base_funds,
		"stock_limits": opts.get("stock_limits", stock_limits),
		"restock_interval": int(opts.get("restock_interval", 3)),
		"restock_counter": 0,
		"sell_ratio": float(opts.get("sell_ratio", 0.5)),
	}


func get_shop_def(shop_name: String) -> Dictionary:
	var def: Dictionary = shop_defs.get(shop_name, {})
	return def


func get_stock_count(shop_name: String, item_name: String) -> int:
	var def: Dictionary = get_shop_def(shop_name)
	if def.is_empty():
		return 0
	return int(def.get("stock_limits", {}).get(item_name, 0))


func get_funds(shop_name: String) -> int:
	return int(get_shop_def(shop_name).get("funds", 0))


## 购买：检查库存、商店资金、玩家金币，成功则扣库存并转移物品
func try_buy(shop_name: String, item: ItemData) -> bool:
	if item == null or not shop_defs.has(shop_name):
		return false
	var def: Dictionary = shop_defs[shop_name]
	var stock := int(def["stock_limits"].get(item.item_name, 0))
	if stock <= 0:
		return false
	if int(def["funds"]) < item.price:
		return false
	if not PartyWallet.can_afford(item.price):
		return false
	if not GBIS.inventory_service.add_item(team_inventory_name, item):
		return false
	def["stock_limits"][item.item_name] = stock - 1
	def["funds"] = int(def["funds"]) - item.price
	PartyWallet.spend(item.price)
	return true


## 出售：受当前商店资金限制，不会无限收购
func try_sell(item: ItemData) -> bool:
	if item == null:
		return false
	var sell_price: int = int(item.get_sell_price()) if item.has_method("get_sell_price") else int(max(1, item.price / 2))
	var def: Dictionary = shop_defs.get(current_shop_name, {})
	if not def.is_empty() and int(def.get("funds", 0)) < sell_price:
		return false
	PartyWallet.earn(sell_price)
	if not def.is_empty():
		def["funds"] = int(def["funds"]) - sell_price
	GBIS.moving_item_service.clear_moving_item()
	return true


## 所有商店按各自周期补货
func restock_all_shops() -> void:
	for shop_name in shop_defs:
		restock_shop(shop_name)


func restock_shop(shop_name: String) -> void:
	var def: Dictionary = shop_defs.get(shop_name, {})
	if def == null:
		return
	def["restock_counter"] = int(def.get("restock_counter", 0)) + 1
	if int(def["restock_counter"]) < int(def.get("restock_interval", 3)):
		return
	def["restock_counter"] = 0
	var limits: Dictionary = {}
	for good in def["goods"]:
		if good is ItemData:
			limits[good.item_name] = limits.get(good.item_name, 0) + 1
	def["stock_limits"] = limits
	def["funds"] = int(def.get("base_funds", 200))


## 打开指定商店
func open_shop(shop_name: String) -> void:
	if not shop_defs.has(shop_name):
		push_error("[ShopManager] 未注册商店：%s" % shop_name)
		return
	current_shop_name = shop_name
	InventoryContext.current_shop_name = shop_name
	if _shop_layer == null or not is_instance_valid(_shop_layer):
		_shop_layer = CanvasLayer.new()
		_shop_layer.name = "ShopLayer"
		_shop_layer.layer = 100
		get_tree().root.add_child(_shop_layer)
	if _shop_ui == null or not is_instance_valid(_shop_ui):
		_shop_ui = ShopUIScene.instantiate()
		_shop_ui.set_process_unhandled_input(false)
		_shop_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_shop_layer.add_child(_shop_ui)
		UiManager.register_ui(_shop_ui)
	_shop_ui.open_shop(shop_name, shop_defs[shop_name])
	_shop_ui.show()
	UiManager.open_ui(_shop_ui)
	shop_opened.emit(shop_name)


## 关闭当前商店
func close_shop() -> void:
	current_shop_name = ""
	InventoryContext.current_shop_name = ""
	if _shop_ui and is_instance_valid(_shop_ui):
		UiManager.close_ui(_shop_ui)
		_shop_ui.hide()
	shop_closed.emit()


## 存档：记录每个商店的等级、资金、库存和补货计数
func serialize() -> Dictionary:
	var shops: Dictionary = {}
	for shop_name in shop_defs:
		var def: Dictionary = shop_defs[shop_name]
		shops[shop_name] = {
			"tier": def.get("tier", 1),
			"funds": def.get("funds", 0),
			"base_funds": def.get("base_funds", 200),
			"stock_limits": def.get("stock_limits", {}),
			"restock_counter": def.get("restock_counter", 0),
		}
	return {"shops": shops}


func get_save_data() -> Dictionary:
	return serialize()


func deserialize(data: Dictionary) -> void:
	if not data.has("shops"):
		return
	for shop_name in data["shops"]:
		if not shop_defs.has(shop_name):
			continue
		var saved: Dictionary = data["shops"][shop_name]
		var def: Dictionary = shop_defs[shop_name]
		def["tier"] = saved.get("tier", def.get("tier", 1))
		def["funds"] = saved.get("funds", def.get("funds", 0))
		def["base_funds"] = saved.get("base_funds", def.get("base_funds", 200))
		def["stock_limits"] = saved.get("stock_limits", def.get("stock_limits", {}))
		def["restock_counter"] = saved.get("restock_counter", 0)


func apply_save_data(data: Dictionary) -> void:
	deserialize(data)
