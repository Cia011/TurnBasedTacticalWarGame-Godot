extends MarginContainer
@onready var 城镇主页按钮: Button = $MarginContainer/HBoxContainer/左侧按钮界面/MarginContainer2/菜单栏目/城镇主页按钮
@onready var 招募界面按钮: Button = $MarginContainer/HBoxContainer/左侧按钮界面/MarginContainer2/菜单栏目/招募界面按钮
@onready var 商店界面按钮: Button = $MarginContainer/HBoxContainer/左侧按钮界面/MarginContainer2/菜单栏目/商店界面按钮
@onready var 任务界面按钮: Button = $MarginContainer/HBoxContainer/左侧按钮界面/MarginContainer2/菜单栏目/任务界面按钮
@onready var 离开城镇按钮: Button = $MarginContainer/HBoxContainer/左侧按钮界面/MarginContainer2/菜单栏目/离开城镇按钮

@onready var 城镇主页: MarginContainer = $MarginContainer/HBoxContainer/右侧内容界面/UImanager/城镇主页
@onready var 招募界面: MarginContainer = $MarginContainer/HBoxContainer/右侧内容界面/UImanager/招募界面

var current_interface:String = "城镇主页"

var can_recruit:bool = true #可以招募角色,有酒馆,人才市场等场所
var can_recruit_units:Array[UnitData]

func _ready() -> void:
	#点击信号连接
	城镇主页按钮.pressed.connect(change_interface_to.bind("城镇主页"))
	招募界面按钮.pressed.connect(change_interface_to.bind("招募界面"))
	商店界面按钮.pressed.connect(change_interface_to.bind("商店界面"))
	任务界面按钮.pressed.connect(change_interface_to.bind("任务界面"))
	离开城镇按钮.pressed.connect(change_interface_to.bind("离开城镇"))
	
	#招募界面信号连接
	招募界面.signal_recruit.connect(recruit_unit)

	var player_char = UnitData.new()
	player_char.character_name = "兰兰"
	player_char.texture = preload("res://素材/角色/Sprite-0010.png")
	can_recruit_units.append(player_char)
	

func change_interface_to(interface_name:String):
	if current_interface == interface_name:
		return
	match current_interface:
		"城镇主页":
			城镇主页.leave_interface()
		"招募界面":
			招募界面.leave_interface()
	current_interface = interface_name
	match current_interface:
		"城镇主页":
			城镇主页.enter_interface()
		"招募界面":
			招募界面.enter_interface(can_recruit_units)
func recruit_unit(character_id : String):
	print("成功招聘角色")
	for unit in can_recruit_units:
		if unit.character_id == character_id:
			#GameState.player_characters.append(unit)
			GameState.register_unit(unit)
			can_recruit_units.erase(unit)
	招募界面.update(can_recruit_units)
