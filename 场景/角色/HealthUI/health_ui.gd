extends Node2D
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func _ready() -> void:
	pass
	
func set_up(max_health,current_health):
	progress_bar.max_value = max_health
	progress_bar.value=current_health
	label.text = str(current_health)
func update(new_health):
	if progress_bar.value == new_health:
		return
	progress_bar.value = max(new_health,0)
	label.text = str(new_health)
