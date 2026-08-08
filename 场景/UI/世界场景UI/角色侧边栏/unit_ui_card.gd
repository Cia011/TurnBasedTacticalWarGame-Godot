extends Panel
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var unit_data : UnitData


func _ready() -> void:
	GBIS.sig_slot_item_equipped.connect(_on_equipment_changed)
	GBIS.sig_slot_item_unequipped.connect(_on_equipment_changed)
	GBIS.sig_slot_refresh.connect(_on_slots_refreshed)


func set_up(unit_data:UnitData):
	self.unit_data = unit_data
	label.text = unit_data.character_name
	refresh_portrait()


func refresh_portrait() -> void:
	if unit_data:
		var portrait := CharacterPortraitService.get_portrait_texture(unit_data, Vector2i(40, 40))
		texture_rect.texture = portrait


func _on_equipment_changed(_slot_name: String = "", _item_data: ItemData = null) -> void:
	refresh_portrait()


func _on_slots_refreshed() -> void:
	refresh_portrait()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_clik"):
		#尝试拦截事件
		accept_event();
		print("click")
		UiManager.show_unit_data.emit(unit_data)
