class_name BaseEquipment
extends BaseItem
@export_category("装备属性")
@export var 槽位类型: String  # "武器", "盔甲", "饰品"

@export_category("基础属性加成")

@export var 生命值: int = 0
@export var 伤害: int = 0
@export var 力量: int = 0
@export var 敏捷:int = 0
@export var 体质:int = 0
@export var 智力:int = 0
@export var 意志力:int = 0#士气

@export var 护甲:int = 0

@export var 简单动作次数:int = 0
@export var 标准动作次数:int = 0

@export var 攻击范围:int = 0



@export_category("特殊效果")
#@export var 被动效果: Array[被动效果]
#@export var 装备效果: Array[Buff效果]

func get_stat_bonuses() -> Dictionary:
	return {
		"生命值": 生命值,
		"伤害": 伤害,
		"力量": 力量,
		"敏捷": 敏捷,
		"体质": 体质,
		"智力": 智力,
		"意志力": 意志力,
		"简单动作次数": 简单动作次数,
		"标准动作次数": 标准动作次数,
		"护甲" : 护甲
	}
