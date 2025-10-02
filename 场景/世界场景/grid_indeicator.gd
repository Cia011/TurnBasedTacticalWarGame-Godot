extends Node2D

var mouse_grid_position : Vector2i

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	#在UI界面时隐藏格子光标
	if UiManager.have_ui_opening():
		visible = false
		return
	visible = true
	
	var new_mouse_grid_position = WorldGridManager.get_mouse_grid_position()
	if new_mouse_grid_position != mouse_grid_position:
		mouse_grid_position = new_mouse_grid_position
		global_position = WorldGridManager.get_world_position(mouse_grid_position)
