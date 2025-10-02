extends MarginContainer
const 属性显示标签 = preload("res://场景/UI/世界场景UI/角色属性栏/属性显示标签.tscn")
@onready var 属性显示容器: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/属性显示容器

@onready var exit: Button = $exit

func _ready() -> void:
	
	UiManager.register_ui(self)
	
	UiManager.show_unit_data.connect(show_unit_data)
func set_up(unit_data:UnitData):
	for 标签 in 属性显示容器.get_children():
		标签.queue_free()
	
	var unit_stats:Dictionary = unit_data.get_states()
	for key in unit_stats:
		var 显示标签实例 = 属性显示标签.instantiate()
		属性显示容器.add_child(显示标签实例)
		显示标签实例.set_up(str(key),str(unit_stats[key]))
		
func show_unit_data(unit_data:UnitData)->void:
	
	UiManager.open_ui(self)
	
	set_up(unit_data)
	show()


func _on_exit_pressed() -> void:
	
	UiManager.close_ui(self)
	
	visible = false
