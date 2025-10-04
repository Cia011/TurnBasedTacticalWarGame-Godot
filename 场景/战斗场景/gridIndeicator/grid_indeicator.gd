extends Node2D

var mouse_grid_position : Vector2i
@onready var label: Label = $Label

func _ready() -> void:
	pass
func _physics_process(delta: float) -> void:
	var new_mouse_grid_position = BattleGridManager.get_mouse_grid_position()
	if new_mouse_grid_position != mouse_grid_position:
		mouse_grid_position = new_mouse_grid_position
		global_position = BattleGridManager.get_world_position(mouse_grid_position)
		var text = str(mouse_grid_position)+'\n'
		text+=str(BattleGridManager.get_grid_data(mouse_grid_position))+'\n'
		text+=str(BattleGridManager.get_grid_unit(mouse_grid_position))
		label.text = text
