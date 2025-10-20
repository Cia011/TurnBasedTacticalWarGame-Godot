class_name BaseEquipment
extends BaseItem
@export_category("装备属性")

@export_category("基础属性加成")
@export var defense: int = 0			#防御-细分物抗魔抗 未实现
@export var agility : int = 0		#敏捷-影响回合,闪避
@export var strength:int = 0			#力量-影响攻击伤害
@export var constitution:int = 0		#体质-影响负重,生命值
@export var intelligence:int = 0		#智力-影响蓝量,魔法攻击伤害

@export var action_points : int = 0		#行动力,回合可使用行动力数量

#@export var max_health: int = 100		#最大生命值
#@export var current_health: int = 100	#当前生命值

func get_properties()->Dictionary:
	var properties:Dictionary = super.get_properties()
	properties.merge({
		"defense":defense,
		"agility":agility,
		"strength":strength,
		"constitution":constitution,
		"intelligence":intelligence,
		"action_points":action_points
	})
	return properties

func restore_from_data(data: Dictionary)->bool:
	super.restore_from_data(data)
	 # 恢复装备特有的属性
	defense = data.get("defense", defense)
	agility = data.get("agility", agility)
	strength = data.get("strength", strength)
	constitution = data.get("constitution", constitution)
	intelligence = data.get("intelligence", intelligence)
	action_points = data.get("action_points", action_points)

	return true
#静态创建方法
static func create_from_data(data: Dictionary) -> BaseEquipment:
	var equipment = BaseEquipment.new()
	if equipment.restore_from_data(data):
		print("创建装备成功 装备名称为:"+str(equipment.item_name))
		return equipment
	else:
		push_error("创建失败")
		return null
