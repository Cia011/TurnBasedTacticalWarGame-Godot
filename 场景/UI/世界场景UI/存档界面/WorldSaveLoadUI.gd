extends Control
class_name WorldSaveLoadUI

@onready var save_slots_container = $MarginContainer/VBoxContainer/SaveSlotsContainer
@onready var message_label = $MarginContainer/VBoxContainer/MessageLabel
@onready var close_button = $MarginContainer/VBoxContainer/CloseButton

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
	
	# 获取存档列表
	var save_slots = WorldSaveManager.get_save_slots()
	
	# 创建存档槽
	for i in range(WorldSaveManager.MAX_SAVE_SLOTS):

		var save_slot = save_slot_scene.instantiate()
		save_slots_container.add_child(save_slot)
		var slot_data:Dictionary
		if save_slots[i]:
			slot_data = save_slots[i]
		else:
			slot_data = {}
		save_slot.set_slot_data(i, slot_data)
		save_slot.save_pressed.connect(_on_save_pressed.bind(i))
		save_slot.load_pressed.connect(_on_load_pressed.bind(i))
		save_slot.delete_pressed.connect(_on_delete_pressed.bind(i))

# 保存按钮点击
func _on_save_pressed(slot_index: int):
	if WorldSaveManager.save_game(slot_index):
		message_label.text = "世界存档已保存到槽位 " + str(slot_index + 1)
		_refresh_save_slots()
	else:
		message_label.text = "保存失败！只能在世界地图场景存档"

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

# 关闭按钮点击
func _on_close_button_pressed():
	hide_ui()
