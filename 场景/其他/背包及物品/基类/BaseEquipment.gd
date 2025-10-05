class_name BaseEquipment
extends BaseItem
@export_category("装备属性")

@export_category("基础属性加成")
@export var defense: int = 5			#防御-细分物抗魔抗 未实现
@export var agility : int = 5		#敏捷-影响回合,闪避
@export var strength:int = 5			#力量-影响攻击伤害
@export var Constitution:int = 5		#体质-影响负重,生命值
@export var Intelligence:int = 5		#智力-影响蓝量,魔法攻击伤害

@export var action_points : int = 5		#行动力,回合可使用行动力数量

#@export var max_health: int = 100		#最大生命值
#@export var current_health: int = 100	#当前生命值

#@export_category("特殊效果")
#@export var 被动效果: Array[被动效果]
#@export var 装备效果: Array[Buff效果]
#
#func get_stat_bonuses() -> Dictionary:
	#return {
		#"生命值": 生命值,
		#"伤害": 伤害,
		#"力量": 力量,
		#"敏捷": 敏捷,
		#"体质": 体质,
		#"智力": 智力,
		#"意志力": 意志力,
		#"简单动作次数": 简单动作次数,
		#"标准动作次数": 标准动作次数,
		#"护甲" : 护甲
	#}
