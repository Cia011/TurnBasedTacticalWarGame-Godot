extends Control
class_name SaveUI

@onready var title_label: Label = $Center/Panel/Margin/VBox/Header/TitleLabel
@onready var name_input: LineEdit = $Center/Panel/Margin/VBox/NameRow/NameInput
@onready var save_button: Button = $Center/Panel/Margin/VBox/Buttons/SaveButton
@onready var load_button: Button = $Center/Panel/Margin/VBox/Buttons/LoadButton
@onready var delete_button: Button = $Center/Panel/Margin/VBox/Buttons/DeleteButton
@onready var close_button: Button = $Center/Panel/Margin/VBox/Header/CloseButton
@onready var save_list: ItemList = $Center/Panel/Margin/VBox/ListPanel/Margin/ItemList
@onready var hint_label: Label = $Center/Panel/Margin/VBox/HintLabel

var _mode := "save"
var _selected_path := ""
var _saves: Array[Dictionary] = []


func _ready() -> void:
	UiManager.register_ui(self)
	close_button.pressed.connect(close)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	save_list.item_selected.connect(_on_item_selected)
	name_input.text_submitted.connect(func(_text: String) -> void:
		_on_save_pressed()
	)
	load_button.disabled = true
	delete_button.disabled = true


func open_save() -> void:
	_mode = "save"
	title_label.text = "保存游戏"
	name_input.editable = true
	name_input.text = ""
	save_button.visible = true
	load_button.visible = false
	refresh_list()
	visible = true
	UiManager.open_ui(self)
	name_input.grab_focus()


func open_load() -> void:
	_mode = "load"
	title_label.text = "读取存档"
	name_input.editable = false
	name_input.text = ""
	save_button.visible = false
	load_button.visible = true
	refresh_list()
	visible = true
	UiManager.open_ui(self)
	load_button.grab_focus()


func toggle_save() -> void:
	if visible:
		close()
	else:
		open_save()


func toggle_load() -> void:
	if visible:
		close()
	else:
		open_load()


func close() -> void:
	visible = false
	UiManager.close_ui(self)


func refresh_list() -> void:
	_saves = WorldSaveManager.get_saves()
	save_list.clear()
	_selected_path = ""
	load_button.disabled = true
	delete_button.disabled = true
	if _saves.is_empty():
		hint_label.text = "暂无存档"
		return
	hint_label.text = "共 %d 个存档，按时间倒序" % _saves.size()
	for save in _saves:
		var save_name := str(save.get("save_name", "未命名存档"))
		var time_text := _format_time(float(save.get("modified_at", 0.0)))
		save_list.add_item("%s    %s" % [save_name, time_text])


func _on_item_selected(index: int) -> void:
	if index < 0 or index >= _saves.size():
		return
	_selected_path = str(_saves[index].get("path", ""))
	load_button.disabled = _selected_path.is_empty()
	delete_button.disabled = _selected_path.is_empty()


func _on_save_pressed() -> void:
	var save_name := name_input.text.strip_edges()
	if save_name.is_empty():
		save_name = "未命名存档"
	var path := WorldSaveManager.save_game(save_name)
	if path.is_empty():
		return
	name_input.text = ""
	refresh_list()


func _on_load_pressed() -> void:
	if _selected_path.is_empty():
		return
	var path := _selected_path
	close()
	WorldSaveManager.load_game(path)


func _on_delete_pressed() -> void:
	if _selected_path.is_empty():
		return
	WorldSaveManager.delete_save(_selected_path)
	refresh_list()


func _format_time(unix_time: float) -> String:
	if unix_time <= 0.0:
		return "未知时间"
	return Time.get_datetime_string_from_unix_time(int(unix_time), false)
