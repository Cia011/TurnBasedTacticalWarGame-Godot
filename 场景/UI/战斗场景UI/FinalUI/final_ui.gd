extends MarginContainer
@onready var exit: Button = $FinalUI2/VBoxContainer/exit
@onready var title: Label = $FinalUI2/VBoxContainer/title


func _on_exit_pressed() -> void:
	GameState.change_scene_to("world")
func set_up(title:String,text:String):
	self.exit.text = text
	self.title.text = title
	visible = true
