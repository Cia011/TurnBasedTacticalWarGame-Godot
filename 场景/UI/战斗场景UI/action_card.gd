extends Button
class_name ActionCardUI
var action : BaseAction

signal signal_action_selected(action : BaseAction)


func _ready() -> void:
	pressed.connect(on_button_pressed)

#当按下技能UI时,发送signal_action_selected信号
func on_button_pressed():
	signal_action_selected.emit(action)

func set_up(action:BaseAction):
	self.action = action
	text = action.action_name
