extends Node
## 商店管理组件（自动加载：ShopManager）
## 负责注册多个商店、打开/关闭商店界面，可轻松扩展新商店。

signal shop_opened(shop_name: String)
signal shop_closed

const ShopUIScene := preload("res://场景/UI/商店UI/shop_ui.tscn")

## 商店定义：shop_name -> {goods: Array[ItemData], columns: int, rows: int}
var shop_defs: Dictionary = {}
var current_shop_name: String = ""

var _shop_layer: CanvasLayer
var _shop_ui: Control

## 注册一个商店
func register_shop(shop_name: String, goods: Array, columns: int = 6, rows: int = 4) -> void:
	shop_defs[shop_name] = {
		"goods": goods,
		"columns": columns,
		"rows": rows,
	}

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
