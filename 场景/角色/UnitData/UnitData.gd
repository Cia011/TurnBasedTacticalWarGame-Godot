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
 #装备和物品
var equipments: BaseBackpack

var buffs: Dictionary = {}  # id -> BaseBuff

var data_manager : DataManager

var equipments_types : Array[String] = [	"武器","头盔","护甲","靴子","武器",
										"戒指","项链","腰带","手套","戒指"]

func _init() -> void:
	var time = Time.get_unix_time_from_system()
	var random_component = randi() % 10000
	character_id = str(int(time*10000)+random_component)
	
	equipments = BaseBackpack.new()
	equipments.items.resize(10)
	
	equipments.item_change.connect(item_change)
	
	data_manager = DataManager.new()
	data_manager.initialize(get_states())

func add_equipment(item:BaseItem)->bool:
	for index in equipments_types.size():
		var type:String = equipments_types[index]
		if type == item.item_type:
			if equipments.get_item(index) == null:
				equipments.set_item(index,item)
				return true
	return false

#待实现
func item_change(indexs):
	for index in indexs:
		pass

## 视觉表现
@export var texture: Texture2D

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
