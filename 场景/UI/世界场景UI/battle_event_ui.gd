extends MarginContainer
@onready var title: Label = $MarginContainer2/Panel/VBoxContainer/Title
@onready var description: Label = $MarginContainer2/Panel/VBoxContainer/Description
@onready var button_1: Button = $MarginContainer2/Panel/VBoxContainer/Button1
@onready var button_2: Button = $MarginContainer2/Panel/VBoxContainer/Button2



func _ready() -> void:
	
	UiManager.register_ui(self)
	
	button_1.pressed.connect(on_button_1_pressed)
	button_2.pressed.connect(on_button_2_pressed)

func set_up(event:BaseEvent):
	UiManager.open_ui(self)
	title.text = event.name
	description.text = event.description

#触发 全局事件
func on_button_1_pressed():
	UiManager.close_ui(self)
	print("进入战斗")
	self.queue_free()
	GameState.change_scene_to("battle")
func on_button_2_pressed():
	UiManager.close_ui(self)
	print("逃跑")
	self.queue_free()
