extends PanelContainer
## 物品信息面板：监听 GBIS 焦点信号，显示当前查看物品的名称、类型、属性、价格、描述。
class_name ItemInfoPanel

@onready var name_label: Label = $Margin/VBox/NameLabel
@onready var type_label: Label = $Margin/VBox/TypeLabel
@onready var desc_label: Label = $Margin/VBox/DescLabel
@onready var price_label: Label = $Margin/VBox/PriceLabel

func _ready() -> void:
	GBIS.sig_item_focused.connect(_on_item_focused)
	GBIS.sig_item_focus_lost.connect(_on_item_focus_lost)
	_clear()

func _on_item_focused(item_data: ItemData, _container_name: String) -> void:
	name_label.text = item_data.item_name
	var price: Variant = item_data.get("price")
	price_label.text = "价格：%d" % price if price != null else ""
	if item_data.has_method("get_display_info"):
		var info: String = item_data.call("get_display_info")
		# get_display_info 已包含全部信息，直接展示
		type_label.text = ""
		desc_label.text = info
	else:
		type_label.text = "类型：%s" % item_data.type
		desc_label.text = ""

func _on_item_focus_lost(_item_data: ItemData) -> void:
	_clear()

func _clear() -> void:
	name_label.text = "物品信息"
	type_label.text = ""
	desc_label.text = "将鼠标悬停在物品上查看详情"
	price_label.text = ""
