extends MarginContainer
signal menu_button_pressed(name:String)
@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(on_button_pressed)
	button.text = self.name

func on_button_pressed():
	menu_button_pressed.emit(self.name)
