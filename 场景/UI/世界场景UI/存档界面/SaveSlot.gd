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

# 设置存档槽数据
func set_slot_data(slot_index: int, slot_data: Dictionary):
	# 保存槽位索引到类的变量中
	self.slot_index = slot_index
	
	slot_label.text = "存档槽 " + str(slot_index + 1)
	
	if slot_data.is_empty():
		info_label.text = "空存档"
		save_button.visible = true
		load_button.visible = false
		delete_button.visible = false
	else:
		# 显示存档信息
		var timestamp = slot_data.get("timestamp", 0)
		var scene_name = slot_data.get("current_scene_name", "未知场景")
		var play_time = slot_data.get("game_progress_data", {}).get("play_time", 0)
		
		# 格式化时间显示
		var time_string = _format_timestamp(timestamp)
		var play_time_string = _format_play_time(play_time)
		
		info_label.text = "场景: %s\n时间: %s\n游戏时长: %s" % [scene_name, time_string, play_time_string]
		save_button.visible = false
		load_button.visible = true
		delete_button.visible = true

# 格式化时间戳为可读格式
func _format_timestamp(timestamp: float) -> String:
	if timestamp <= 0:
		return "未知时间"
	
	var datetime = Time.get_datetime_dict_from_unix_time(int(timestamp))
	return "%d年%d月%d日 %02d:%02d" % [
		datetime["year"],
		datetime["month"],
		datetime["day"],
		datetime["hour"],
		datetime["minute"]
	]

# 格式化游戏时长
func _format_play_time(play_time: float) -> String:
	if play_time <= 0:
		return "0分钟"
	
	var hours = int(play_time) / 3600
	var minutes = int(play_time) % 3600 / 60
	
	if hours > 0:
		return "%d小时%d分钟" % [hours, minutes]
	else:
		return "%d分钟" % minutes

func _on_save_button_pressed():
	save_pressed.emit(slot_index)

func _on_load_button_pressed():
	load_pressed.emit(slot_index)

func _on_delete_button_pressed():
	delete_pressed.emit(slot_index)
