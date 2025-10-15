extends Node

# 玩家队伍
signal signal_player_characters_change
var player_characters: Array[UnitData] = []
var enemy_characters: Array[UnitData] = []
var baseteam_node : BaseTeam

# 当前战斗信息
var current_battle_info: Dictionary = {}
#战斗准备阶段,放置角色位置
var preparatory_phase = true
var is_battleing = false

#var is_open_UI : bool = false

#-------------------------------------
#----------------背包部分--------------
var all_backpacks : Array[BaseBackpack]

var on_mouse_slot_item : BaseItem
#此信号0接受
signal signal_mouse_slot_change(item:BaseItem)
func set_mouse_slot_item(item:BaseItem):
	on_mouse_slot_item = item
	signal_mouse_slot_change.emit(item)
func get_mouse_slot_item()->BaseItem:
	signal_mouse_slot_change.emit(on_mouse_slot_item)
	return on_mouse_slot_item
#add/remove
func add_backpack(backpack:BaseBackpack):
	all_backpacks.append(backpack)
func remove_backpack(backpack:BaseBackpack):
	all_backpacks.erase(backpack)
#------------------------------------------
#///////////////////////////
signal scenes_ready(scenes_name:String)

# 初始化示例角色
func _ready():
	#is_open_UI = true
	
	# 创建示例玩家角色
	var player_char = UnitData.new()
	player_char.character_name = "第一个角色"
	player_char.texture = preload("res://素材/角色/Sprite-0010.png")
	register_unit(player_char)
	
	var player_char2 = UnitData.new()
	player_char2.character_name = "第二个角色"
	player_char2.texture = preload("res://素材/角色/Sprite-0010.png")
	
	var equpment1 = BaseEquipment.new()
	equpment1.item_name = "小刀"
	equpment1.texture = preload("res://素材/角色/Sprite-0010.png")
	equpment1.item_type = "武器"
	equpment1.defense = 100
	player_char2.equipments.add_item(equpment1)
	
	var attack_buff = AttackBuff.new()
	player_char2.buff_manager.add_buff(attack_buff)
	print(player_char2.get_final_stat("defense"))
	
	#player_characters.append(player_char2)
	register_unit(player_char2)
	
	var enemy_char = UnitData.new()
	enemy_char.character_name = "敌人"
	enemy_char.texture = preload("res://素材/角色/Sprite-0010.png")
	enemy_characters.append(enemy_char)
	
	

func register_unit(unit:UnitData) -> void:
	player_characters.append(unit)
	signal_player_characters_change.emit()
func unregister_unit(unit:UnitData) -> void:
	player_characters.erase(unit)
	signal_player_characters_change.emit()
	
	
	## 创建示例敌人
	#var enemy_char = UnitData.new()
	#enemy_char.character_name = "Goblin"
	#enemy_char.level = 1
	#enemy_char.max_health = 50
	#enemy_char.current_health = 50
	#enemy_char.attack = 8
	#enemy_char.defense = 3
	#enemy_char.speed = 7
	#enemy_char.move_range = 4
	#enemy_char.texture = preload("res://assets/characters/goblin.png")
	#
	#enemy_characters.append(enemy_char)
# 准备战斗数据
func prepare_battle(player_chars: Array[UnitData], enemy_chars: Array[UnitData], battle_type: String = "normal"):
	current_battle_info = {
		"player_characters": [],
		"enemy_characters": [],
		"battle_type": battle_type,
		"battle_environment": "forest", # 或其他环境类型
		"turn_order": []
	}
	# 保存角色状态副本
	for char_data in player_chars:
		current_battle_info["player_characters"].append(char_data.save_state())
	for char_data in enemy_chars:
		current_battle_info["enemy_characters"].append(char_data.save_state())


func change_scene_to(scene:String):
	match scene:
		"battle":
			get_tree().change_scene_to_file("res://场景/战斗场景/根节点/battle_map.tscn")
		"world":
			get_tree().change_scene_to_file("res://场景/世界场景/WorldScenes.tscn")


# 重置游戏状态
func reset_game_state():
	print("[GameState] 重置游戏状态")
	
	# 清空玩家角色列表
	player_characters.clear()
	
	# 重置队伍节点引用
	baseteam_node = null
	
	# 重置其他游戏状态变量
	# 根据您的项目结构添加其他需要重置的变量
