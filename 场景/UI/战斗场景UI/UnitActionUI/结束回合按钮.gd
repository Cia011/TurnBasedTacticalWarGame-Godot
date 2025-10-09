extends Button
func _ready() -> void:
	pressed.connect(on_button_pressed)

func set_up(unit:Unit):
	if unit.is_teammate == false:
		disabled = true
	else:
		disabled = false

func on_button_pressed():
	if BattleActionManager.is_performing_action:
		return
	BattleTurnManager.set_next_turn_unit()
