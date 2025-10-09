extends Button
func _ready() -> void:
	pressed.connect(on_button_pressed)


func on_button_pressed():
	if BattleActionManager.is_performing_action:
		return
	BattleTurnManager.set_next_turn_unit()
