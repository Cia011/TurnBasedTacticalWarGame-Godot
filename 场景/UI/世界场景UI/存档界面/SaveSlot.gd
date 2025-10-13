extends HBoxContainer
class_name SaveSlot

signal save_pressed(slot_index: int)
signal load_pressed(slot_index: int)
signal delete_pressed(slot_index: int)

@onready var slot_label = $SlotLabel
@onready var info_label = $InfoLabel
@onready var save_button = $SaveButton
@onready var load_button = $LoadButton
@onready var delete_button = $DeleteButton

var slot_index: int = -1
func _ready() -> void:
	$SaveButton.pressed.connect(_on_save_button_pressed)
	$LoadButton.pressed.connect(_on_load_button_pressed)
	$DeleteButton.pressed.connect(_on_delete_button_pressed)
func set_slot_data(index: int, slot_data: Dictionary):
	slot_index = index
	slot_label.text = "存档槽 " + str(index + 1)
	
	if slot_data:
		var timestamp = slot_data.get("timestamp", 0)
		var player_name = slot_data.get("player_name", "未知玩家")
		var level = slot_data.get("level", 1)
		var scene_name = slot_data.get("scene_name", "未知场景")
		
		var date_time = Time.get_datetime_dict_from_unix_time(timestamp)
		var time_str = "%04d-%02d-%02d %02d:%02d" % [
			date_time.year, date_time.month, date_time.day,
			date_time.hour, date_time.minute
		]
		
		info_label.text = "玩家: %s | 等级: %d | 场景: %s | 时间: %s" % [player_name, level, scene_name, time_str]
		save_button.disabled = false
		load_button.disabled = false
		delete_button.disabled = false
	else:
		info_label.text = "空存档槽"
		save_button.disabled = false
		load_button.disabled = true
		delete_button.disabled = true

func _on_save_button_pressed():
	save_pressed.emit()

func _on_load_button_pressed():
	load_pressed.emit()

func _on_delete_button_pressed():
	delete_pressed.emit()
