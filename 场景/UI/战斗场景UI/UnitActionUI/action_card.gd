extends Button
class_name ActionCardUI
var action : BaseAction
@onready var label: Label = $Label

signal signal_action_selected(action : BaseAction)


func _ready() -> void:
	pressed.connect(on_button_pressed)

#当按下技能UI时,发送signal_action_selected信号
func on_button_pressed():
	signal_action_selected.emit(action)

func set_up(action:BaseAction = null):
	if action == null:
		self.action = null
		label.text = ""
		self.disabled = true
		self.icon = null
	else:
		self.action = action
		label.text = action.action_name
		self.disabled = false
		self.icon = action.action_icon
		if action.unit.is_teammate == false:
			self.disabled = true
		else:
			self.disabled = false
