class_name CharacterStatsCalculator

# 基础属性 + 装备加成 + buff/debuff = 最终属性
static func calculate_final_stats(unit_data: UnitData) -> Dictionary:
	var base_stats = unit_data.get_states()
	var equipment_bonus = _calculate_equipment_bonus(unit_data)
	var buff_bonus = _calculate_buff_bonus(unit_data)  # 如果有buff系统
	
	var final_stats = {}

	# 计算每个最终属性
	for stat in base_stats:
		var base_value = base_stats[stat]
		var equipment_value = equipment_bonus.get(stat, 0)
		var buff_value = buff_bonus.get(stat, 0)
		
		final_stats[stat] = base_value + equipment_value + buff_value
	
	# 特殊处理：生命值不能超过最大值
	final_stats["current_health"] = min(final_stats["current_health"], final_stats["max_health"])
	
	return final_stats

static func _calculate_equipment_bonus(unit_data: UnitData) -> Dictionary:
	var bonus = {
		"defense": 0,
		"agility": 0,
		"strength": 0,
		"Constitution": 0,
		"Intelligence": 0,
		"max_health": 0,
		"action_points": 0
	}
	
	# 遍历所有装备计算加成
	for i in range(unit_data.equipments.items.size()):
		var item = unit_data.equipments.items[i]
		if item and item is BaseItem:
			_add_item_bonus(bonus, item)
	
	return bonus

static func _add_item_bonus(bonus: Dictionary, item: BaseItem):
	# 假设BaseItem有properties字典，包含属性加成
	if item.has_method("get_properties"):
		var properties = item.get_properties()
		for property in properties:
			if bonus.has(property):
				bonus[property] += properties[property]

static func _calculate_buff_bonus(unit_data: UnitData) -> Dictionary:
	# 如果有buff系统，在这里计算
	# 暂时返回空字典
	return {}
