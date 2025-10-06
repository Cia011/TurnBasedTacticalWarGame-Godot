class_name BaseEquipment
extends BaseItem
@export_category("装备属性")

@export_category("基础属性加成")
@export var defense: int = 5			#防御-细分物抗魔抗 未实现
@export var agility : int = 5		#敏捷-影响回合,闪避
@export var strength:int = 5			#力量-影响攻击伤害
@export var constitution:int = 5		#体质-影响负重,生命值
@export var intelligence:int = 5		#智力-影响蓝量,魔法攻击伤害

@export var action_points : int = 0		#行动力,回合可使用行动力数量

#@export var max_health: int = 100		#最大生命值
#@export var current_health: int = 100	#当前生命值

func get_properties()->Dictionary:
	return {
		"defense":defense,
		"agility":agility,
		"strength":strength,
		"constitution":constitution,
		"intelligence":intelligence,
		"action_points":action_points
	}
