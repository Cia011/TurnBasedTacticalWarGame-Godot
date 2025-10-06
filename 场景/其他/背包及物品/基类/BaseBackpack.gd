extends Resource
class_name BaseBackpack

@export var items : Array[BaseItem]
@export var name : String

signal item_change(indexs)
signal backpack_full()
signal backpack_emptied()

func 唯一化(index):
	items[index] = items[index].duplicate(true)

# 验证索引有效性
func is_valid_index(index: int) -> bool:
	return index == -1 or (index >= 0 and index < items.size())
func get_item_count() -> int:
	var count = 0
	for item in items:
		if item:
			count += 1
	return count

func get_total_capacity() -> int:
	return items.size()

func is_full() -> bool:
	return get_item_count() >= get_total_capacity()
#交换索引上的物品
#func swap_item(index,target_index):
	##交换鼠标与槽里的物品
	#if index == -1:
		#var mouse_slot_item = GameState.get_mouse_slot_item()
		#GameState.set_mouse_slot_item(items[target_index])
#
		#items[target_index] = mouse_slot_item
#
	#else:
		#var item = items[index]
		#var target_item = items[target_index]
		#if (item is BaseItem and target_item is BaseItem):
			#if item.item_name == target_item.item_name and item.max_stack > 1:
				#target_item.number += item.number
				#remove_item(index)
		#else:
			#items[target_index] = item
			#items[index] = target_item
	#item_change.emit([index,target_index])

# 改进的交换方法
func swap_item(source_index: int, target_index: int) -> void:
	print("swap")
	
	if not is_valid_index(source_index) or not is_valid_index(target_index):
		push_error("Invalid indices in swap_item")
		return
	
	if source_index == target_index:
		return
	
	# 处理鼠标槽位交换
	if source_index == -1:
		print("理鼠标槽位交换")
		var mouse_slot_item = GameState.get_mouse_slot_item()
		var target_item = get_item(target_index)
		
		items[target_index] = mouse_slot_item
		GameState.set_mouse_slot_item(target_item)
		
		item_change.emit([target_index])
		return
	
	# 正常物品交换
	var source_item = get_item(source_index)
	var target_item = get_item(target_index)
	
	items[source_index] = target_item
	items[target_index] = source_item
	
	item_change.emit([source_index, target_index])


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

#func add_item(item,number:int = -1):
	#
	#for index in range(0,items.size()):
		#if items[index] == null:
			#set_item(index,item,number)
			#
			#break
		#
# 改进的添加物品方法
func add_item(item: BaseItem, number: int = -1) -> bool:
	if not item:
		return false
	
	var remaining = number if number >= 0 else item.number
	
	# 先尝试堆叠
	remaining = try_stack_to_existing(item.item_name, remaining)
	if remaining <= 0:
		return true
	
	# 再找空位
	return try_find_empty_slot(item, remaining)

# 尝试堆叠到已有物品
func try_stack_to_existing(item_name: String, amount: int) -> int:
	var remaining = amount
	
	for i in range(items.size()):
		var existing = items[i]
		if existing and existing.item_name == item_name and existing.number < existing.max_stack:
			var space = existing.max_stack - existing.number
			var transfer = min(remaining, space)
			
			existing.number += transfer
			remaining -= transfer
			
			item_change.emit([i])
			
			if remaining <= 0:
				break
	
	return remaining

# 尝试找空位
func try_find_empty_slot(item: BaseItem, amount: int) -> bool:
	for i in range(items.size()):
		if items[i] == null:
			var new_item = item.duplicate(true)
			new_item.number = amount
			items[i] = new_item
			item_change.emit([i])
			
			if get_item_count() >= items.size():
				backpack_full.emit()
			
			return true
	
	return false 


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
	elif index >=0 and index < items.size():
		return items[index]
	else:
		return null
