extends MarginContainer
@onready var v_box_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	GameState.signal_player_characters_change.connect(up_date_texture)
	up_date_texture()
 
func up_date_texture():
	var team_size = GameState.player_characters.size()
	for index in v_box_container.get_children().size():
		if index < team_size:
			v_box_container.get_child(index).visible = true
			v_box_container.get_child(index).set_up(GameState.player_characters[index])
		else:
			v_box_container.get_child(index).visible = false
