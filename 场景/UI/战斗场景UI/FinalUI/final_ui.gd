extends MarginContainer
@onready var exit: Button = $FinalUI2/VBoxContainer/exit
@onready var title: Label = $FinalUI2/VBoxContainer/title


func _on_exit_pressed() -> void:
	UiManager.unregister_ui(self)
	GameState.change_scene_to("world")
	
	
func set_up(title:String,text:String):
	self.exit.text = text
	self.title.text = title
	visible = true
func _ready() -> void:
	UiManager.register_ui(self)
