extends Resource
class_name BaseBackpack

@export var items : Array[BaseItem]
@export var name : String

signal item_change(indexs)

func 唯一化(index):
	items[index] = items[index].duplicate(true)

#交换索引上的物品
func swap_item(index,target_index):
	#交换鼠标与槽里的物品
	if index == -1:
		var mouse_slot_item = GameState.get_mouse_slot_item()
		GameState.set_mouse_slot_item(items[target_index])

		items[target_index] = mouse_slot_item

	else:
		var item = items[index]
		var target_item = items[target_index]
		if (item is BaseItem and target_item is BaseItem):
			if item.item_name == target_item.item_name and item.max_stack > 1:
				target_item.number += item.number
				remove_item(index)
		else:
			items[target_index] = item
			items[index] = target_item
	item_change.emit([index,target_index])
#移除索引上的物品
func remove_item(index):
	if index == -1:
		GameState.set_mouse_slot_item(null)
	else:
		items[index] = null
	item_change.emit([index])
#设置索引物品
func set_item(index:int,item:BaseItem,number:int = -1):
	if item == null:return
	
	if index == -1:
		if number < 0:
			item = item.duplicate(true)
			GameState.set_mouse_slot_item(item)
		elif number == 0:
			GameState.set_mouse_slot_item(null)
		else:
			item = item.duplicate(true)
			GameState.set_mouse_slot_item(item)
			GameState.get_mouse_slot_item().number = number
	
	else:
		if number < 0:
			item = item.duplicate(true)
			items[index] = item
		elif number == 0:
			items[index] = null
		else:
			items[index] = item.duplicate(true)
			items[index].number = number
	item_change.emit([index])

func add_item(item,number:int = -1):
	
	for index in range(0,items.size()):
		if items[index] == null:
			set_item(index,item,number)
			
			break
		
func reduce_item():
	pass

func add_item_number(index,number):
	if index == -1:
		GameState.get_mouse_slot_item().number += number
	else:
		items[index].number += number
	item_change.emit([index])

func reduce_item_number(index,number):
	if index == -1:
		GameState.get_mouse_slot_item().number -= number
		if GameState.get_mouse_slot_item().number<= 0:
			remove_item(index)
	else:
		items[index].number -= number
		if items[index].number <= 0:
			remove_item(index)
	item_change.emit([index])
#索引处剩余可堆叠数量
func surplus_stack(index) -> int:
	if index == -1:
		return GameState.get_mouse_slot_item().max_stack - GameState.get_mouse_slot_item().number
	elif items[index] == null:return -1
	return items[index].max_stack-items[index].number
#物品名称是否相同
func name_is_same(index,target_index)->bool:
	if index == -1 and get_item(target_index):
		return GameState.get_mouse_slot_item().item_name == items[target_index].item_name
	
	elif get_item(index) and get_item(target_index):
		return items[index].item_name == items[target_index].item_name
	else:return false
func get_item(index)->BaseItem:
	if index == -1:
		return GameState.get_mouse_slot_item()
	return items[index]
