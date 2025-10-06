extends MarginContainer
class_name 装备栏ui
@export var 槽位容器: GridContainer
var 背包系统 : BaseBackpack


@onready var label: Label = $HBoxContainer/VBoxContainer/标题/Label

const SLOT = preload("res://场景/其他/背包及物品/基类/slot.tscn")

func _ready() -> void:
	UiManager.show_unit_data.connect(on_unit_card_clik)
	
	for index in 槽位容器.get_child_count():
		var slot:BaseBagSlot = 槽位容器.get_child(index)
		slot.gui_input.connect(Callable(self,"_on_gui_input").bind(index))
		slot.数量显示.text = ""
	#visible = false
	if UiManager.current_show_data_unit:
		set_up(UiManager.current_show_data_unit)
	else:
		set_up(GameState.player_characters.front())
	
func on_unit_card_clik(unit_data:UnitData):
	#print("equipments:"+str(unit_data.equipments))
	set_up(unit_data)
	
func set_up(unit_data:UnitData):
	#visible = true
	if 背包系统:
		背包系统.item_change.disconnect(Callable(self,"_item_change"))
	背包系统 = unit_data.equipments

	背包系统.item_change.connect(Callable(self,"_item_change"))
	
	背包系统.items.resize(槽位容器.get_child_count())
	
	for index in 槽位容器.get_child_count():
		update_slot([index])
	
	label.text = unit_data.character_name + " 的装备栏"
#向背包中添加物品
func add_item(item:BaseItem,number:int = -1):
	背包系统.add_item(item,number)


func update_slot(indexs):
	for index in indexs:
		#由index获取slot
		var slot:BaseBagSlot = 槽位容器.get_child(index)
		slot.set_item(背包系统.items[index])


func _item_change(indexs):
	update_slot(indexs)

#func _on_gui_input(event:InputEvent,index):
	#if event is InputEventMouseButton and event.pressed:
		##print(index)
		#accept_event()#标记事件
		#
		##判断类别
		#if (GameState.on_mouse_slot_item):
			#if(GameState.on_mouse_slot_item.item_type != 槽位容器.get_child(index).slot_type):
				#return
		#
		#var e = event as InputEventMouseButton
		#if e.button_index == MOUSE_BUTTON_LEFT:
			#背包系统.swap_item(-1,index)
		#elif e.button_index == MOUSE_BUTTON_RIGHT:
			#if GameState.get_mouse_slot_item() != null:#手上有物品
				#if 背包系统.get_item(index):#目标格子有物品
					#if 背包系统.surplus_stack(index)>0 and 背包系统.name_is_same(-1,index):
						#背包系统.add_item_number(index,1) #目标物品加1
						#背包系统.reduce_item_number(-1,1) #鼠标物品减1
				#else:#目标格子没有物品
					#背包系统.set_item(index,GameState.get_mouse_slot_item(),1)
					#背包系统.reduce_item_number(-1,1)
func _on_gui_input(event: InputEvent, index: int):
	if not _is_valid_mouse_click(event):
		return
	
	accept_event()
	
	if not _is_item_type_compatible(index):
		return
	
	var mouse_event := event as InputEventMouseButton
	
	match mouse_event.button_index:
		MOUSE_BUTTON_LEFT:
			_handle_left_click(index)
		MOUSE_BUTTON_RIGHT:
			_handle_right_click(index)

func _is_valid_mouse_click(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and 
			event.pressed and
			(event as InputEventMouseButton).button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT])

func _is_item_type_compatible(index: int) -> bool:
	var mouse_item = GameState.get_mouse_slot_item()
	var slot_type = 槽位容器.get_child(index).slot_type
	
	if not mouse_item or slot_type == null:
		return true
	
	return mouse_item.item_type == slot_type

func _handle_left_click(index: int):
	if 背包系统.is_valid_index(index):
		背包系统.swap_item(-1, index)
	else:
		push_warning("无效的槽位索引: %d" % index)

func _handle_right_click(index: int):
	if not 背包系统.is_valid_index(index):
		push_warning("无效的槽位索引: %d" % index)
		return
	
	var mouse_item = GameState.get_mouse_slot_item()
	var target_item = 背包系统.get_item(index)
	
	if mouse_item:
		_handle_right_click_with_item(index, mouse_item, target_item)

func _handle_right_click_with_item(index: int, mouse_item, target_item):
	if target_item and _can_stack_items(mouse_item, target_item, index):
		背包系统.add_item_number(index, 1)
		背包系统.reduce_item_number(-1, 1)
	elif not target_item:
		_place_single_item(index, mouse_item)

func _can_stack_items(source_item, target_item, index: int) -> bool:
	return (source_item.item_name == target_item.item_name and 
			背包系统.surplus_stack(index) > 0)

func _place_single_item(index: int, mouse_item):
	背包系统.set_item(index, mouse_item, 1)
	背包系统.reduce_item_number(-1, 1)
