extends MarginContainer
class_name 基本背包ui

@export var 槽位容器: GridContainer
@export var 背包系统 : BaseBackpack

signal mouse_0_change(物品:BaseItem)

func _ready() -> void:
	
	UiManager.register_ui(self)
	
	背包系统.item_change.connect(Callable(self,"_item_change"))
	for index in 槽位容器.get_children().size():
		update_slot([index])
		if index == 0:continue
		if not 槽位容器.get_child(index):continue
		if not 槽位容器.get_child(index).is_usable:continue#若设置不可用则不进行信号连接
		槽位容器.get_child(index).gui_input.connect(Callable(self,"_on_gui_input").bind(index))
	
func update_slot(indexs):
	for index in indexs:
		槽位容器.get_child(index).set_item(背包系统.items[index])

func _item_change(indexs):
	update_slot(indexs)
	if indexs.has(0):
		mouse_0_change.emit(背包系统.get_item(0))

func _on_gui_input(event:InputEvent,index):
	if event is InputEventMouseButton and event.pressed:
		#print(index)
		accept_event()#标记事件
		
		
		#判断类别
		if (背包系统.get_item(0)):
			if(背包系统.get_item(0).item_type != 槽位容器.get_child(index).slot_type):
				return
		
		var e = event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			背包系统.swap_item(0,index)
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			if 背包系统.get_item(0) != null:#手上有物品
				if 背包系统.get_item(index):#目标格子有物品
					if 背包系统.surplus_stack(index)>0 and 背包系统.name_is_same(0,index):
						背包系统.add_item_number(index,1)
						背包系统.reduce_item_number(0,1)
				else:#目标格子没有物品
					背包系统.set_item(index,背包系统.get_item(0),1)
					背包系统.reduce_item_number(0,1)


func _on_exit_pressed() -> void:
	UiManager.close_ui(self)
	#visible = false
	
