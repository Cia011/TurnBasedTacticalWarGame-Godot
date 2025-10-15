extends Control
class_name WorldSaveLoadUI

@onready var save_slots_container = $MarginContainer/VBoxContainer/SaveSlotsContainer
@onready var message_label = $MarginContainer/VBoxContainer/MessageLabel
@onready var close_button = $MarginContainer/VBoxContainer/CloseButton
@onready var bottom_save_button = $MarginContainer/VBoxContainer/BottomSaveButton

# 存档槽预制场景
var save_slot_scene = preload("res://场景/UI/世界场景UI/存档界面/SaveSlot.tscn")

# 显示/隐藏界面
func show_ui():
	visible = true
	_refresh_save_slots()

func hide_ui():
	visible = false

# 刷新存档槽显示
func _refresh_save_slots():
	# 清空现有槽位
	for child in save_slots_container.get_children():
		child.queue_free()
	
	# 获取非空存档列表（按时间倒序排列）
	var non_empty_slots = WorldSaveManager.get_non_empty_save_slots()
	
	# 只显示非空存档槽
	for slot_data in non_empty_slots:
		var save_slot = save_slot_scene.instantiate()
		save_slots_container.add_child(save_slot)
		
		var slot_index = slot_data.get("slot_index", -1)
		if slot_index >= 0:
			save_slot.set_slot_data(slot_index, slot_data)
			save_slot.load_pressed.connect(_on_load_pressed)
			save_slot.delete_pressed.connect(_on_delete_pressed)

# 加载按钮点击
func _on_load_pressed(slot_index: int):
	if await WorldSaveManager.load_game(slot_index):
		message_label.text = "正在加载世界存档..."
		hide_ui()
	else:
		message_label.text = "加载失败！"

# 删除按钮点击
func _on_delete_pressed(slot_index: int):
	if WorldSaveManager.delete_save(slot_index):
		message_label.text = "存档已删除"
		_refresh_save_slots()
	else:
		message_label.text = "删除失败！"

# 底部保存按钮点击 - 自动创建最新存档
func _on_bottom_save_button_pressed():
	# 找到第一个可用的空槽位
	var available_slot_index = _find_available_save_slot()
	
	if available_slot_index >= 0:
		if WorldSaveManager.save_game(available_slot_index):
			message_label.text = "已自动创建新存档到槽位 " + str(available_slot_index + 1)
			_refresh_save_slots()
		else:
			message_label.text = "保存失败！只能在世界地图场景存档"
	else:
		message_label.text = "存档槽已满，无法创建新存档"

# 查找可用的存档槽位
func _find_available_save_slot() -> int:
	var save_slots = WorldSaveManager.get_save_slots()
	for i in range(save_slots.size()):
		if save_slots[i] == null:  # 空槽位
			return i
	return -1  # 没有可用槽位

# 关闭按钮点击
func _on_close_button_pressed():
	hide_ui()
