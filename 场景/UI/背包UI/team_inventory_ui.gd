extends Control
## 队伍背包界面：左侧队伍背包网格，右侧选中角色装备栏 + 物品信息。

const TEAM_INVENTORY := "TeamInventory"

@onready var title_label: Label = $Margin/VBox/Header/TitleLabel
@onready var money_label: Label = $Margin/VBox/Header/MoneyLabel
@onready var close_button: Button = $Margin/VBox/Header/CloseButton
@onready var inventory_container: Control = $Margin/VBox/Body/Left/InventoryContainer
@onready var equipment_panel: CharacterEquipmentPanel = $Margin/VBox/Body/Right/EquipmentPanel
@onready var item_info_panel: ItemInfoPanel = $Margin/VBox/Body/Right/ItemInfoPanel

var _inventory_view: InventoryView
var selected_unit: UnitData


func _ready() -> void:
	# 创建队伍背包网格视图
	_inventory_view = InventoryView.new()
	_inventory_view.container_name = TEAM_INVENTORY
	_inventory_view.container_columns = 8
	_inventory_view.container_rows = 5
	_inventory_view.base_size = 40
	inventory_container.add_child(_inventory_view)

	# 注册 UI 并连接信号
	UiManager.register_ui(self)
	UiManager.show_unit_data.connect(_on_unit_selected)
	PartyWallet.money_changed.connect(_on_money_changed)
	close_button.pressed.connect(close)

	# 默认选中第一个角色
	if not GameState.player_characters.is_empty():
		select_unit(GameState.player_characters[0])
	print("[背包UI] TeamInventoryUI 就绪，背包视图=%s，队伍人数=%d" % [str(_inventory_view != null), GameState.player_characters.size()])


func open() -> void:
	visible = true
	UiManager.open_ui(self)
	if selected_unit == null and not GameState.player_characters.is_empty():
		select_unit(GameState.player_characters[0])
	_on_money_changed(PartyWallet.money, PartyWallet.money)


func close() -> void:
	visible = false
	UiManager.close_ui(self)


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _on_money_changed(_old_value: int, new_value: int) -> void:
	if money_label:
		money_label.text = "金币：%d" % new_value


func _on_unit_selected(unit_data: UnitData) -> void:
	select_unit(unit_data)


func select_unit(unit_data: UnitData) -> void:
	if unit_data == null:
		return
	selected_unit = unit_data
	InventoryContext.selected_unit_data = unit_data
	equipment_panel.set_unit(unit_data)
