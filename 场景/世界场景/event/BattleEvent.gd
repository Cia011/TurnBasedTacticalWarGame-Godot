
class_name BattleEvent extends BaseEvent

const BATTLE_EVENT_UI = preload("res://场景/UI/世界场景UI/事件触发UI/战斗触发UI/battle_event_ui.tscn")

## 敌人类型（可在编辑器中编辑）
@export var enemy_type: String = "野怪"
## 敌人数量（可在编辑器中编辑）
@export var enemy_count: int = 1

## 敌人队伍信息
var enemy_characters: Array[UnitData] = []

func _init():
	type = "battle"
	name = "遭遇战"
	duration = 1
	description = "前方遭遇了敌人，是否迎战？"

func apply_effect() -> void:
	print("apply_effect")
	if enemy_characters.is_empty():
		build_enemies()
	GameState.enemy_characters = enemy_characters
	trigger_event()
	
func trigger_event():
	print("触发事件"+str(name))
	var battle_event_ui = BATTLE_EVENT_UI.instantiate()
	var UI = UiManager.get_ui("UI")
	UI.add_child(battle_event_ui)
	battle_event_ui.set_up(self)

## 按配置生成敌人
func build_enemies() -> void:
	enemy_characters.clear()
	for i in enemy_count:
		var enemy := UnitData.new()
		enemy.character_name = "%s %d" % [enemy_type, i + 1]
		enemy.level = 1
		enemy_characters.append(enemy)

func serialize() -> Dictionary:
	var data := super.serialize()
	data["enemy_type"] = enemy_type
	data["enemy_count"] = enemy_count
	return data

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	enemy_type = data.get("enemy_type", enemy_type)
	enemy_count = data.get("enemy_count", enemy_count)
	build_enemies()
