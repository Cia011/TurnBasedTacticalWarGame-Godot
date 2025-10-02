extends Node
class_name UnitData

# 基础属性
@export_category("基础属性")
@export var character_name: String = ""	#名称

@export var level: int = 1				#等级

@export var defense: int = 5			#防御-细分物抗魔抗 未实现
@export var agility : int = 5		#敏捷-影响回合,闪避
@export var strength:int = 5			#力量-影响攻击伤害
@export var Constitution:int = 5		#体质-影响负重,生命值
@export var Intelligence:int = 5		#智力-影响蓝量,魔法攻击伤害

@export var action_points : int = 5		#行动力,回合可使用行动力数量

@export var max_health: int = 100		#最大生命值
@export var current_health: int = 100	#当前生命值

#
@export var character_background_story:String
var character_id : String
func _init() -> void:
	var time = Time.get_unix_time_from_system()
	var random_component = randi() % 10000
	character_id = str(int(time*10000)+random_component)
#@export var attack: int = 10
#@export var speed: int = 8
#@export var move_range: int = 4

## 战斗属性
#@export var experience: int = 0
#@export var experience_to_next_level: int = 100
#@export var stata_position : Vector2i = Vector2i(1,1)
## 视觉表现
@export var texture: Texture2D
#@export var color: Color = Color.WHITE
#@export var scale: float = 1.0
#
## 技能和能力
#@export var skills: Array[String] = ["attack", "defend"]
#@export var abilities: Array[String] = []

# 装备和物品
#@export var equipment: Dictionary = {
	#"weapon": "",
	#"armor": "",
	#"accessory": ""
#}
#@export var inventory: Array[String] = []
#
## 状态效果
#@export var status_effects: Array[String] = []

func get_states() -> Dictionary:
	return {
		"character_name" : character_name,
		"level":level,
		"defense":defense,
		"agility":agility,
		"strength":strength,
		"Constitution":Constitution,
		"Intelligence":Intelligence,
		"action_points":action_points,
		"max_health":max_health,
		"current_health":current_health
	}


# 保存当前状态
#func save_state() -> Dictionary:
	#return {
		#"name": character_name,
		#"level": level,
		#"max_health": max_health,
		#"current_health": current_health,
		#"attack": attack,
		#"defense": defense,
		#"speed": speed,
		#"move_range": move_range,
		#"experience": experience,
		#"experience_to_next_level": experience_to_next_level,
		#"skills": skills.duplicate(),
		#"abilities": abilities.duplicate(),
		#"equipment": equipment.duplicate(),
		#"inventory": inventory.duplicate(),
		#"status_effects": status_effects.duplicate()
	#}
#
## 从字典加载状态
#func load_state(data: Dictionary):
	#character_name = data.get("name", "")
	#level = data.get("level", 1)
	#max_health = data.get("max_health", 100)
	#current_health = data.get("current_health", 100)
	#attack = data.get("attack", 10)
	#defense = data.get("defense", 5)
	#speed = data.get("speed", 8)
	#move_range = data.get("move_range", 4)
	#experience = data.get("experience", 0)
	#experience_to_next_level = data.get("experience_to_next_level", 100)
	#skills = data.get("skills", []).duplicate()
	#abilities = data.get("abilities", []).duplicate()
	#equipment = data.get("equipment", {}).duplicate()
	#inventory = data.get("inventory", []).duplicate()
	#status_effects = data.get("status_effects", []).duplicate()
