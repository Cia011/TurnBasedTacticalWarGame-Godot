class_name BuffManager
extends Node

signal buff_added(buff: BaseBuff)
signal buff_removed(buff: BaseBuff)
signal buff_updated(buff: BaseBuff)

var buffs: Dictionary = {}  # id -> BaseBuff
#@onready var 角色:= $".." as 角色
#@export var unit: Unit
var unit_data: UnitData
func _init(unit_data: UnitData) -> void:
	self.unit_data = unit_data
# 添加Buff
func add_buff(buff: BaseBuff) -> bool:
	buff.target = unit_data
	
	# 检查是否已存在相同Buff
	if buffs.has(buff.id):
		var existing_buff = buffs[buff.id]
		if existing_buff.can_stack():
			return existing_buff.add_stack()
		else:
			# 刷新持续时间
			existing_buff.duration = max(existing_buff.duration, buff.duration)
			buff_updated.emit(existing_buff)
			return true
	else:
		# 应用新Buff
		buffs[buff.id] = buff
		buff.apply_effect()
		buff_added.emit(buff)
		return true

# 移除Buff
func remove_buff(buff_id: String) -> bool:
	if buffs.has(buff_id):
		var buff = buffs[buff_id]
		buff.remove_effect()
		buffs.erase(buff_id)
		buff_removed.emit(buff)
		return true
	return false

# 清除所有Buff
func clear_all_buffs():
	for buff_id in buffs.keys():
		remove_buff(buff_id)

# 清除特定类型的所有Buff
func clear_buffs_of_type(buff_type: BaseBuff.BuffType):
	var to_remove = []
	for buff_id in buffs:
		if buffs[buff_id].type == buff_type:
			to_remove.append(buff_id)
	
	for buff_id in to_remove:
		remove_buff(buff_id)

# 回合开始处理
func on_turn_start():
	for buff in buffs.values():
		buff.on_turn_start()

# 回合结束处理
func on_turn_end():
	# 创建副本以避免在迭代中修改字典
	var buffs_copy = buffs.duplicate()
	for buff in buffs_copy.values():
		buff.on_turn_end()

# 获取所有激活的Buff
func get_active_buffs() -> Array:
	return buffs.values()

# 检查是否有特定Buff
func has_buff(buff_id: String) -> bool:
	return buffs.has(buff_id)

# 获取特定Buff
func get_buff(buff_id: String) -> BaseBuff:
	return buffs.get(buff_id)
