extends Panel
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var unit_data : UnitData


func set_up(unit_data:UnitData):
	self.unit_data = unit_data
	label.text = unit_data.character_name

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_clik"):
		#尝试拦截事件
		accept_event();
		print("click")
		UiManager.show_unit_data.emit(unit_data)
