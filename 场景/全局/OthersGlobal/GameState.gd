extends Node
var is_new_game : bool = true
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
	var player_char = create_unit_data({
		"character_name": "第一个角色",
		"texture_path": "res://素材/角色/Sprite-0010.png",
	})
	register_unit(player_char)
	var player_char2 = create_unit_data({
		"character_name": "第二个角色",
		"texture_path": "res://素材/角色/Sprite-0010.png",
	})
	register_unit(player_char2)
		
	var equpment1 = BaseEquipment.create_from_data({
		"item_name": "小刀",
		"id": "1234",
		"texture_path": "res://素材/角色/Sprite-0010.png",
		"item_type": "武器",
		"defense": 100,
	})
	player_char2.equipments.add_item(equpment1)		

	
	# var enemy_char = UnitData.new()
	# enemy_char.character_name = "敌人"
	# enemy_char.texture = preload("res://素材/角色/Sprite-0010.png")
	# enemy_characters.append(enemy_char)
	var enemy_char2 = create_unit_data({
		"character_name": "敌人2",
		"texture_path": "res://素材/角色/Sprite-0010.png",
	})
	register_enemy_unit(enemy_char2)
	print("[gamestate] : ready end")
	

func register_unit(unit:UnitData) -> void:
	player_characters.append(unit)
	signal_player_characters_change.emit()
func unregister_unit(unit:UnitData) -> void:
	player_characters.erase(unit)
	signal_player_characters_change.emit()
func register_enemy_unit(unit:UnitData) -> void:
	enemy_characters.append(unit)


func change_scene_to(scene:String):
	UiManager.close_all_open_ui()
	if scene!= "world" :
		print("[GameState]","实时备份")
		WorldSaveManager.save_game_currrnt()
	match scene:
		"battle":
			is_battleing = true
			get_tree().change_scene_to_file("res://场景/战斗场景/根节点/battle_map.tscn")
		"world":
			is_battleing = false
			WorldSaveManager.load_game_current()
			#get_tree().change_scene_to_file("res://场景/世界场景/WorldScenes.tscn")


# 重置游戏状态
func reset_game_state():
	print("[GameState] 重置游戏状态")
	
	# 清空玩家角色列表
	player_characters.clear()
	
	# 重置队伍节点引用
	baseteam_node = null
	
	# 重置其他游戏状态变量
	# 根据您的项目结构添加其他需要重置的变量


## 角色数据创建工厂
func create_unit_data(data:Dictionary)->UnitData:
	var unit = UnitData.create_from_data(data)
	return unit
