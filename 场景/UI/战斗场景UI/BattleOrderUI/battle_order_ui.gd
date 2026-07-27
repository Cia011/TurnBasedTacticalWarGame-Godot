extends Control

# 战斗顺序UI - 显示所有角色的行动顺序

# 导出变量 - 引用场景中的节点
@export var order_container: HBoxContainer
@export var info_label: Label

# 角色图标容器缓存 (Unit -> VBoxContainer)
var unit_icon_containers: Dictionary = {}

# 初始化
func _ready():
	# 连接信号
	BattleTurnManager.signal_change_unit.connect(_on_unit_changed)
	BattleTurnManager.signal_turn_end.connect(_on_turn_end)
	
	# 角色注册/注销信号
	BattleUnitManager.unit_registered.connect(_on_unit_registered)
	BattleUnitManager.unit_unregistered.connect(_on_unit_unregistered)
	
	# 延迟一帧更新UI（等待单位注册完成）
	call_deferred("_update_order")

# 更新战斗顺序
func _update_order():
	if not order_container:
		return
	
	# 清空现有图标
	for child in order_container.get_children():
		child.queue_free()
	unit_icon_containers.clear()
	
	# 获取单位列表并按敏捷排序（模拟行动顺序）
	var sorted_units = BattleUnitManager.units.duplicate()
	sorted_units.sort_custom(func(a: Unit, b: Unit) -> bool:
		return a.unit_data.get_final_stat("agility") > b.unit_data.get_final_stat("agility")
	)
	
	# 为每个单位创建图标
	for unit in sorted_units:
		_create_unit_icon(unit)

# 创建单位图标
func _create_unit_icon(unit: Unit):
	var icon_container = VBoxContainer.new()
	icon_container.custom_minimum_size = Vector2(64, 75)
	icon_container.layout_mode = 2
	
	# 创建头像按钮（作为图标）
	var icon_button = Button.new()
	icon_button.custom_minimum_size = Vector2(60, 60)
	icon_button.layout_mode = 2
	icon_button.flat = true
	
	# 设置头像纹理
	if unit.unit_data.texture:
		icon_button.icon = unit.unit_data.texture
	else:
		# 使用默认图标
		var default_texture = _create_default_icon(unit.unit_data.character_name, unit.is_teammate)
		if default_texture:
			icon_button.icon = default_texture
	
	icon_container.add_child(icon_button)
	
	# 创建角色名称标签
	var name_label = Label.new()
	name_label.text = unit.unit_data.character_name
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	name_label.layout_mode = 2
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.custom_minimum_size = Vector2(60, 15)
	icon_container.add_child(name_label)
	
	# 保存引用（保存整个容器）
	unit_icon_containers[unit] = icon_container
	order_container.add_child(icon_container)

# 创建默认图标
func _create_default_icon(name: String, is_teammate: bool) -> Texture2D:
	var image = Image.create(60, 60, false, Image.FORMAT_RGBA8)
	
	# 设置背景色
	var bg_color = Color(0.3, 0.3, 0.3) if is_teammate else Color(0.5, 0.2, 0.2)
	image.fill(bg_color)
	
	# 绘制边框
	for i in range(60):
		image.set_pixel(i, 0, Color(0.8, 0.6, 0.4))
		image.set_pixel(i, 59, Color(0.6, 0.4, 0.2))
		image.set_pixel(0, i, Color(0.8, 0.6, 0.4))
		image.set_pixel(59, i, Color(0.6, 0.4, 0.2))
	
	return ImageTexture.create_from_image(image)

# 回合结束时将角色图标移到最后
func _on_turn_end(unit: Unit):
	if not order_container or not unit_icon_containers.has(unit):
		return
	
	# 获取角色的图标容器
	var container = unit_icon_containers[unit]
	
	# 将容器移到最后
	order_container.move_child(container, order_container.get_child_count() - 1)

# 单位切换时更新UI
func _on_unit_changed(unit: Unit):
	if not order_container:
		return
	
	# 重置所有图标样式
	for u in unit_icon_containers:
		var container = unit_icon_containers[u]
		var button = container.get_child(0) as Button
		if button:
			button.scale = Vector2(1, 1)
			button.modulate = Color(1, 1, 1)
	
	# 高亮当前单位
	if unit_icon_containers.has(unit):
		var container = unit_icon_containers[unit]
		var current_button = container.get_child(0) as Button
		if current_button:
			current_button.scale = Vector2(1.15, 1.15)
			current_button.modulate = Color(1.0, 0.85, 0.3)
		
		# 更新信息标签
		if info_label:
			info_label.text = "%s 的回合" % unit.unit_data.character_name

# 手动更新顺序（可以从外部调用）
func refresh_order():
	_update_order()
	if BattleTurnManager.current_unit:
		_on_unit_changed(BattleTurnManager.current_unit)

# 角色注册时添加到UI列表
func _on_unit_registered(unit: Unit):
	if not order_container:
		return
	
	# 创建角色图标
	_create_unit_icon(unit)
	
	# 重新排序（按敏捷）
	_resort_units()
	
	# 更新当前单位高亮
	if BattleTurnManager.current_unit:
		_on_unit_changed(BattleTurnManager.current_unit)

# 角色注销时从UI列表移除
func _on_unit_unregistered(unit: Unit):
	if not order_container:
		return
	
	# 检查是否有该角色的图标
	if unit_icon_containers.has(unit):
		var container = unit_icon_containers[unit]
		container.queue_free()
		unit_icon_containers.erase(unit)
	
	# 更新当前单位高亮
	if BattleTurnManager.current_unit:
		_on_unit_changed(BattleTurnManager.current_unit)

# 按敏捷重新排序角色图标
func _resort_units():
	if not order_container:
		return
	
	# 获取当前所有子节点
	var children = order_container.get_children()
	if children.size() <= 1:
		return
	
	# 获取单位列表
	var units_list = []
	for child in children:
		# 从子节点找到对应的单位
		for u in unit_icon_containers:
			if unit_icon_containers[u] == child:
				units_list.append(u)
				break
	
	# 按敏捷排序
	units_list.sort_custom(func(a: Unit, b: Unit) -> bool:
		return a.unit_data.get_final_stat("agility") > b.unit_data.get_final_stat("agility")
	)
	
	# 按新顺序重新排列子节点
	for i in range(units_list.size()):
		var container = unit_icon_containers[units_list[i]]
		order_container.move_child(container, i)
