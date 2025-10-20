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
func get_serializable_data()->Dictionary:
	var data = {}
	for index in range(items.size()):
		if items[index]:
			data[str(index)] = items[index].get_properties()
	return data

func restore_from_data(equipment_data: Dictionary):
	#清空
	for index in range(items.size()):
		items[index] = null
	# 创建
	for index in equipment_data.keys():
		var slot_data = equipment_data[index]
		var item = _create_item_by_type(slot_data)
		if item:
			set_item(int(index),item)
		


# 根据装备数据创建装备
func _create_item_by_type(item_data: Dictionary) -> BaseItem:
	# 这里需要根据您的装备系统实现具体的装备创建逻辑
	var item_type:String = item_data.get("item_type", "")
	match item_type:
		"武器", "防具", "饰品":
			# 如果是装备类型，创建BaseEquipment
			return BaseEquipment.create_from_data(item_data)
		"任意", "消耗品", "材料":
			# 如果是普通物品，创建BaseItem
			return BaseItem.create_from_data(item_data)
		_:
			# 默认创建BaseItem
			push_warning("未知物品类型: " + item_type + ", 创建基础物品")
			return BaseItem.create_from_data(item_data)
