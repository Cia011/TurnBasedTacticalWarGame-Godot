extends Resource
class_name BaseBackpack

@export var items : Array[BaseItem]
@export var name : String

signal item_change(indexs)

func 唯一化(index):
	items[index] = items[index].duplicate(true)

#交换索引上的物品
func swap_item(index,target_index):
	var item = items[index]
	var target_item = items[target_index]
	if (item is BaseItem and target_item is BaseItem):
		if item.name == target_item.name and item.max_stack > 1:
			target_item.number += item.number
			remove_item(index)
	else:
		items[target_index] = item
		items[index] = target_item
	item_change.emit([index,target_index])
#移除索引上的物品
func remove_item(index):
	items[index] = null
	item_change.emit([index])
#设置索引物品
func set_item(index:int,item:BaseItem,number:int = -1):
	if item == null:return
	
	if number < 0:
		item = item.duplicate(true)
		items[index] = item
	elif number == 0:
		items[index] = null
	else:
		items[index] = null
		items[index].number = number
	item_change.emit([index])

func add_item(item,number:int = 1):
	for index in range(1,items.size()):
		if items[index] == null:
			items[index] = item.duplicate(true)
			items[index].number = number
			item_change.emit([index])
			break
func reduce_item():
	pass

func add_item_number(index,number):
	items[index].number += number
	item_change.emit([index])

func reduce_item_number(index,number):
	items[index].number -= number
	if items[index].number <= 0:
		remove_item(index)
	item_change.emit([index])
#索引处剩余可堆叠数量
func surplus_stack(index) -> int:
	if items[index] == null:return -1
	return items[index].max_stack-items[index].number
#物品名称是否相同
func name_is_same(index,target_index)->bool:
	if get_item(index) and get_item(target_index):
		return items[index].name == items[target_index].name
	else:return false
func get_item(index)->Resource:
	return items[index]
