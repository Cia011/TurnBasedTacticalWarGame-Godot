extends Control
@onready var v_box_container: VBoxContainer = $MarginContainer/MarginContainer/VBoxContainer

func _ready() -> void:
	for button in v_box_container.get_children():
		button.menu_button_pressed.connect(on_menu_button_pressed)
	
	# 检查是否有存档，如果没有则禁用"继续游戏"按钮
	_update_continue_button()

func _update_continue_button():
	var continue_button = _find_button_by_name("继续游戏")
	if continue_button:
		continue_button.disabled = not WorldSaveManager.has_save_data()
		if continue_button.disabled:
			continue_button.text = "继续游戏 (无存档)"
		else:
			continue_button.text = "继续游戏"

func _find_button_by_name(button_name: String) -> Control:
	for button in v_box_container.get_children():
		if button.has_method("get_button_name") and button.get_button_name() == button_name:
			return button
	return null

func on_menu_button_pressed(button_name:String):
	print("[主菜单] " + button_name + " 按钮被点击")
	match button_name:
		"继续游戏":
			_on_continue_game()
		"新建游戏":
			_on_new_game()

# 继续游戏逻辑
func _on_continue_game():
	print("[主菜单] 执行继续游戏")
	GameState.is_new_game = false
	# 获取最新存档槽位索引
	var latest_slot_index = WorldSaveManager.get_latest_save_slot_index()
	#print("latest_slot_index为:",latest_slot_index)
	if latest_slot_index == -1:
		print("[主菜单] 没有找到存档")
		return
	
	print("[主菜单] 加载最新存档，槽位: ", latest_slot_index)
	
	# 加载存档
	if await WorldSaveManager.load_game(latest_slot_index):
		print("[主菜单] 存档加载成功")
	else:
		print("[主菜单] 存档加载失败")

# 新建游戏逻辑
func _on_new_game():
	print("[主菜单] 执行新建游戏")
	
	# 初始化新游戏数据
	_init_new_game()
	
	# 加载初始场景
	var initial_scene_path = "res://场景/世界场景/WorldScenes.tscn"  # 根据您的项目结构调整
	var error = get_tree().change_scene_to_file(initial_scene_path)
	if error != OK:
		push_error("[主菜单] 加载初始场景失败: " + initial_scene_path)

# 初始化新游戏数据
func _init_new_game():
	print("[主菜单] 初始化新游戏数据")
	
	# 清空现有游戏状态
	GameState.reset_game_state()
	
	# 初始化玩家队伍
	_init_player_team()
	
	# 初始化世界地图
	_init_world_map()
	
	# 初始化游戏进度
	_init_game_progress()

# 初始化玩家队伍
func _init_player_team():
	print("[主菜单] 初始化玩家队伍")
	
	# 创建默认角色
	var default_characters = _create_default_characters()
	GameState.player_characters = default_characters
	
	# 设置初始队伍位置
	if GameState.baseteam_node:
		GameState.baseteam_node.set_grid_position(Vector2i(0, 0))

# 创建默认角色
func _create_default_characters() -> Array[UnitData]:
	var characters: Array[UnitData] = []
	
	# 创建默认角色1
	var char1 = UnitData.new()
	char1.character_name = "战士"
	char1.level = 1
	char1.strength = 10
	char1.defense = 8
	characters.append(char1)
	
	# 创建默认角色2
	var char2 = UnitData.new()
	char2.character_name = "法师"
	char2.level = 1
	char2.intelligence = 12
	characters.append(char2)
	
	return characters

# 初始化世界地图
func _init_world_map():
	print("[主菜单] 初始化世界地图")
	# 这里需要根据您的世界地图系统实现具体的初始化逻辑

# 初始化游戏进度
func _init_game_progress():
	print("[主菜单] 初始化游戏进度")
	# 这里需要根据您的游戏进度系统实现具体的初始化逻辑
