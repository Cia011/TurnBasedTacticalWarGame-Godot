extends MarginContainer
class_name 基本商店ui

@export var 槽位容器: GridContainer
@export var 背包系统 : BaseBackpack
const SLOT = preload("res://场景/其他/背包及物品/基类/slot.tscn")


func _ready() -> void:
	
	UiManager.register_ui(self)
	背包系统.item_change.connect(Callable(self,"_item_change"))
	

func set_up(size:int):
	背包系统.items.resize(size)
	for index in size:
		var new_slot = SLOT.instantiate()
		槽位容器.add_child(new_slot)
		new_slot.name = str(index)
		
		
		update_slot([index])
		if not 槽位容器.get_child(index):continue
		if not 槽位容器.get_child(index).is_usable:continue#若设置不可用则不进行信号连接
		槽位容器.get_child(index).gui_input.connect(Callable(self,"_on_gui_input").bind(index))
#向背包中添加物品
func add_item(item:BaseItem,number:int = -1):
	背包系统.add_item(item,number)

func update_slot(indexs):
	for index in indexs:
		槽位容器.get_child(index).set_item(背包系统.items[index])

func _item_change(indexs):
	update_slot(indexs)

func _on_gui_input(event:InputEvent,index):
	if event is InputEventMouseButton and event.pressed:
		#print(index)
		accept_event()#标记事件
		
		#判断类别
		#if (背包系统.get_item(0)):
			#if(背包系统.get_item(0).item_type != 槽位容器.get_child(index).slot_type):
				#return
		
		var e = event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			背包系统.swap_item(-1,index)
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			if GameState.get_mouse_slot_item() != null:#手上有物品
				if 背包系统.get_item(index):#目标格子有物品
					if 背包系统.surplus_stack(index)>0 and 背包系统.name_is_same(-1,index):
						背包系统.add_item_number(index,1) #目标物品加1
						背包系统.reduce_item_number(-1,1) #鼠标物品减1
				else:#目标格子没有物品
					背包系统.set_item(index,GameState.get_mouse_slot_item(),1)
					背包系统.reduce_item_number(-1,1)

func leave_interface():
	GameState.remove_backpack(背包系统)
	visible = false
	
func enter_interface():
	GameState.add_backpack(背包系统)
	visible = true
