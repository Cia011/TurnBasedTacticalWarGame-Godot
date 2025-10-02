extends MarginContainer
##存放招聘栏的文件夹
@onready var 招募栏容器: VBoxContainer = $HBoxContainer/MarginContainer/ScrollContainer/MarginContainer/招聘栏容器
const 招募栏 = preload("res://场景/UI/世界场景UI/TownSceneUI/招募栏.tscn")
@onready var 角色介绍标签: Label = $HBoxContainer/角色信息显示/ScrollContainer/MarginContainer/角色介绍标签
@onready var scroll_container: ScrollContainer = $HBoxContainer/角色信息显示/ScrollContainer

signal signal_recruit(character_id : String)


func leave_interface():
	visible = false
func enter_interface(character_datas:Array[UnitData]):
	visible = true
	set_up(character_datas)
	
func update(character_datas:Array[UnitData]):
	set_up(character_datas)

func set_up(character_datas:Array[UnitData]):
	for node in 招募栏容器.get_children():
		node.queue_free()
	
	for character in character_datas:
		var 招募栏实例 = 招募栏.instantiate()
		招募栏容器.add_child(招募栏实例)
		
		var character_id : String = character.character_id
		招募栏实例.set_up(character)
		招募栏实例.signal_recruit.connect(recruit.bind(character_id))
		招募栏实例.signal_select_role.connect(select_role.bind(character_id))

#点击了对应角色的招募按钮
func recruit(character_id : String):

	self.signal_recruit.emit(character_id)
	scroll_container.visible = false
	#select_role("")
	
#选择了对应角色,查看信息,背景故事

func select_role(character_id : String):
	scroll_container.visible = true
	角色介绍标签.text = character_id
