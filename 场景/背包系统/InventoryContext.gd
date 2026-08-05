extends Node
## 背包交互上下文（自动加载：InventoryContext）
## 记录当前选中的角色、当前打开的商店等 UI 状态，供物品逻辑访问。

signal selected_unit_changed(unit_data: UnitData)

var selected_unit_data: UnitData:
	set(value):
		selected_unit_data = value
		selected_unit_changed.emit(value)
var current_shop_name: String = ""
