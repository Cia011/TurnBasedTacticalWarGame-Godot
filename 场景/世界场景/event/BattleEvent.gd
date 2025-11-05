
class_name BattleEvent extends BaseEvent
#@export var battle_event_ui_scenes : PackedScene

const BATTLE_EVENT_UI = preload("res://场景/UI/世界场景UI/事件触发UI/战斗触发UI/battle_event_ui.tscn")
## 敌人队伍信息
var enemy_characters: Array[UnitData] = []

func _init():
	type = "battle"

func apply_effect() -> void:
	print("apply_effect")
	GameState.enemy_characters = enemy_characters
	trigger_event()
	
func trigger_event():
	print("触发事件"+str(name))
	var battle_event_ui = BATTLE_EVENT_UI.instantiate()
	var UI = UiManager.get_ui("UI")
	UI.add_child(battle_event_ui)
	battle_event_ui.set_up(self)
func serialize() -> Dictionary:
	var data:Dictionary = super.serialize()
	# 序列化敌人队伍信息
	data["enemy_characters"] = []
	for enemy in enemy_characters:
		data["enemy_characters"].append(enemy.serialize())
	return data
func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	# 反序列化敌人队伍信息
	enemy_characters = []
	for enemy_data in data.get("enemy_characters", []):
		var enemy = GameState.create_unit_data({
		"character_name": "敌人2",
		"texture_path": "res://素材/角色/Sprite-0010.png",
		})
		enemy_characters.append(enemy)
