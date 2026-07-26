extends Control

# 测试背包名称
const TEST_INVENTORY_NAME = "TestInventory"

# 导出变量 - 在场景中连接
@export var item_info_label: Label

# 初始化背包视图
func _ready():
	# 配置快速移动关系（两个背包之间）
	GBIS.add_quick_move_relation(TEST_INVENTORY_NAME, "SecondaryInventory")
	
	# 监听物品信息信号
	GBIS.sig_item_focused.connect(_on_item_focused)
	GBIS.sig_item_focus_lost.connect(_on_item_focus_lost)
	
	# 连接按钮信号（通过代码实现）
	_connect_button_signals()
	
	# 添加初始测试物品
	_add_initial_items()

# 通过代码连接按钮信号
func _connect_button_signals():
	# 获取按钮节点
	var add_item_button = get_node("MainContainer/ButtonPanel/ButtonContainer/AddItemButton")
	var add_consumable_button = get_node("MainContainer/ButtonPanel/ButtonContainer/AddConsumableButton")
	var add_equipment_button = get_node("MainContainer/ButtonPanel/ButtonContainer/AddEquipmentButton")
	var clear_button = get_node("MainContainer/ButtonPanel/ButtonContainer/ClearButton")
	var save_button = get_node("MainContainer/ButtonPanel/ButtonContainer/SaveButton")
	var load_button = get_node("MainContainer/ButtonPanel/ButtonContainer/LoadButton")
	
	# 连接信号
	add_item_button.pressed.connect(_on_add_item_button_pressed)
	add_consumable_button.pressed.connect(_on_add_consumable_button_pressed)
	add_equipment_button.pressed.connect(_on_add_equipment_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)

# 添加初始测试物品
func _add_initial_items():
	_add_test_item("剑", "武器", "res://素材/图标/iton/剑.png")
	_add_test_consumable("生命药水", "消耗品", "res://素材/图标/slot/slot.png")
	_add_test_consumable("魔法药水", "消耗品", "res://素材/图标/slot/slot.png")
	_add_test_equipment("铁甲", "盔甲", "res://素材/图标/slot/盔甲slot.png")

# 创建并添加测试物品
func _add_test_item(name: String, item_type: String, icon_path: String):
	var item = ItemData.new()
	item.item_name = name
	item.type = item_type
	item.icon = load(icon_path)
	item.columns = 1
	item.rows = 1
	GBIS.add_item(TEST_INVENTORY_NAME, item)

# 创建并添加测试消耗品
func _add_test_consumable(name: String, item_type: String, icon_path: String):
	var item = ConsumableData.new()
	item.item_name = name
	item.type = item_type
	item.icon = load(icon_path)
	item.columns = 1
	item.rows = 1
	item.stack_size = 10
	item.current_amount = 5
	GBIS.add_item(TEST_INVENTORY_NAME, item)

# 创建并添加测试装备
func _add_test_equipment(name: String, item_type: String, icon_path: String):
	var item = EquipmentData.new()
	item.item_name = name
	item.type = item_type
	item.icon = load(icon_path)
	item.columns = 1
	item.rows = 1
	GBIS.add_item(TEST_INVENTORY_NAME, item)

# 显示物品信息
func _on_item_focused(item_data: ItemData, container_name: String):
	if not item_info_label:
		return
	
	var info = "物品: %s\n类型: %s\n尺寸: %dx%d" % [item_data.item_name, item_data.type, item_data.columns, item_data.rows]
	if item_data is StackableData:
		info += "\n数量: %d/%d" % [item_data.current_amount, item_data.stack_size]
	if item_data is ConsumableData:
		info += "\n可消耗"
	if item_data is EquipmentData:
		info += "\n可装备"
	
	item_info_label.text = info

# 清除物品信息
func _on_item_focus_lost(item_data: ItemData):
	if item_info_label:
		item_info_label.text = "鼠标悬停在物品上查看信息"

# 添加物品按钮
func _on_add_item_button_pressed():
	var item_names = ["药水", "宝石", "卷轴", "钥匙", "食物"]
	var random_name = item_names[randi() % item_names.size()]
	_add_test_item(random_name, "物品", "res://素材/图标/slot/slot.png")

# 添加消耗品按钮
func _on_add_consumable_button_pressed():
	var item_names = ["能量药水", "解毒剂", "复活药", "经验药水"]
	var random_name = item_names[randi() % item_names.size()]
	_add_test_consumable(random_name, "消耗品", "res://素材/图标/slot/slot.png")

# 添加装备按钮
func _on_add_equipment_button_pressed():
	var equipment = [
		{"name": "长剑", "type": "武器", "icon": "res://素材/图标/iton/剑.png"},
		{"name": "皮甲", "type": "盔甲", "icon": "res://素材/图标/slot/盔甲slot.png"},
		{"name": "皮靴", "type": "靴子", "icon": "res://素材/图标/slot/靴子.png"},
		{"name": "戒指", "type": "饰品", "icon": "res://素材/图标/slot/戒指slot.png"},
	]
	var random_equip = equipment[randi() % equipment.size()]
	_add_test_equipment(random_equip["name"], random_equip["type"], random_equip["icon"])

# 清空背包按钮
func _on_clear_button_pressed():
	var container_data = GBIS.inventory_service.get_container(TEST_INVENTORY_NAME)
	if container_data:
		for item_data in container_data.item_grids_map.keys():
			GBIS.inventory_service.remove_item(TEST_INVENTORY_NAME, item_data)
	
	var secondary_data = GBIS.inventory_service.get_container("SecondaryInventory")
	if secondary_data:
		for item_data in secondary_data.item_grids_map.keys():
			GBIS.inventory_service.remove_item("SecondaryInventory", item_data)

# 保存按钮
func _on_save_button_pressed():
	GBIS.save()

# 加载按钮
func _on_load_button_pressed():
	await GBIS.load()
