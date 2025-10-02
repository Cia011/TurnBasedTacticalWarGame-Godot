extends MarginContainer
@onready var 角色名称按钮: Button = $HBoxContainer/MarginContainer/角色名称按钮
@onready var 招募按钮: Button = $HBoxContainer/MarginContainer2/招募按钮

var role_data : UnitData

signal signal_select_role
signal signal_recruit

func _ready() -> void:
	角色名称按钮.pressed.connect(select_role)
	招募按钮.pressed.connect(recruit)
func set_up(role_data : UnitData):
	角色名称按钮.text =  role_data.get_states()["character_name"]

func select_role():
	signal_select_role.emit()

func recruit():
	signal_recruit.emit()
