extends Node

# 存档相关常量
const SAVE_DIRECTORY = "user://world_saves/"
const SAVE_FILE_PREFIX = "world_save_"
const CURRENT_SAVE_FILE_PREFIX = "current_save"
const SAVE_FILE_EXTENSION = ".json"
const MAX_SAVE_SLOTS = 10

# 当前存档数据
var current_save_data: Dictionary

func _ready():
	# 确保目录存在
	_create_save_directory()

# 创建存档目录
func _create_save_directory():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIRECTORY):
		dir.make_dir(SAVE_DIRECTORY)

# 检查是否可以在当前场景存档
func can_save_in_current_scene() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return false
	
	# 检查是否为世界地图场景
	var scene_path = current_scene.scene_file_path
	var scene_name = current_scene.name
	
	# 根据您的项目结构调整这些条件
	return (scene_path.contains("world") or 
			scene_path.contains("World") or 
			scene_name.contains("world") or
			scene_name.contains("World"))

# 保存游戏
func save_game(slot_index: int = 0) -> bool:
	if not can_save_in_current_scene():
		push_error("无法在当前场景存档：只能在世界地图场景存档")
		return false
	
	if slot_index < 0 or slot_index >= MAX_SAVE_SLOTS:
		push_error("存档槽索引无效：" + str(slot_index))
		return false
	
	# 收集存档数据
	current_save_data = _collect_save_data()
	 
	# 保存到文件
	var file_path = SAVE_DIRECTORY + SAVE_FILE_PREFIX + str(slot_index) + SAVE_FILE_EXTENSION
	return _save_to_file(file_path, current_save_data)
# 实时存档
func save_game_currrnt() -> bool:
	if not can_save_in_current_scene():
		push_error("无法在当前场景存档：只能在世界地图场景存档")
		return false
	# 收集存档数据
	current_save_data = _collect_save_data()
	# 保存到文件
	var file_path = SAVE_DIRECTORY + CURRENT_SAVE_FILE_PREFIX + SAVE_FILE_EXTENSION
	return _save_to_file(file_path, current_save_data)


# 加载游戏
func load_game(slot_index: int = 0) -> bool:
	if slot_index < 0 or slot_index >= MAX_SAVE_SLOTS:
		push_error("存档槽索引无效：" + str(slot_index))
		return false
	
	var file_path = SAVE_DIRECTORY + SAVE_FILE_PREFIX + str(slot_index) + SAVE_FILE_EXTENSION
	current_save_data = _load_from_file(file_path)
	
	if current_save_data == null:
		return false
	
	# 恢复游戏状态
	return await _restore_game_state()
# 实时加载
func load_game_current() -> bool:
	var file_path = SAVE_DIRECTORY + CURRENT_SAVE_FILE_PREFIX + SAVE_FILE_EXTENSION
	current_save_data = _load_from_file(file_path)
	if current_save_data == null:
		return false
	# 恢复游戏状态
	return await _restore_game_state()
# 删除存档
func delete_save(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_SAVE_SLOTS:
		return false
	
	var file_path = SAVE_DIRECTORY + SAVE_FILE_PREFIX + str(slot_index) + SAVE_FILE_EXTENSION
	var dir = DirAccess.open("user://")
	return dir.remove(file_path) == OK

# 获取存档列表
func get_save_slots() -> Array:
	var slots = []
	for i in range(MAX_SAVE_SLOTS):
		var file_path = SAVE_DIRECTORY + SAVE_FILE_PREFIX + str(i) + SAVE_FILE_EXTENSION
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			
			file.close()
			if data:
				slots.append(data)
			else:
				slots.append(null)
		else:
			slots.append(null)
	return slots

# 获取非空存档列表（按时间倒序排列）
func get_non_empty_save_slots() -> Array:
	var all_slots = get_save_slots()
	var non_empty_slots = []
	
	# 收集非空存档
	for i in range(all_slots.size()):
		if all_slots[i] != null:
			var slot_data = all_slots[i].duplicate(true)
			slot_data["slot_index"] = i  # 保存原始槽位索引
			non_empty_slots.append(slot_data)
	
	# 按时间戳倒序排列（最新的在前）
	non_empty_slots.sort_custom(func(a, b): 
		return a.get("timestamp", 0) > b.get("timestamp", 0)
	)
	
	return non_empty_slots

# 获取最新存档的槽位索引
func get_latest_save_slot_index() -> int:
	var non_empty_slots = get_non_empty_save_slots()
	if non_empty_slots.is_empty():
		return -1  # 没有存档
	return non_empty_slots[0].get("slot_index", -1)

# 检查是否有存档
func has_save_data() -> bool:
	return not get_non_empty_save_slots().is_empty()

# 收集存档数据
func _collect_save_data() -> Dictionary:
	var save_data = {}
	
	# 保存时间戳
	save_data["timestamp"] = Time.get_unix_time_from_system()
	save_data["version"] = "1.0.0"
	
	# 保存当前场景信息
	var current_scene = get_tree().current_scene
	save_data["current_scene_path"] = current_scene.scene_file_path
	save_data["current_scene_name"] = current_scene.name
	
	# 收集玩家队伍数据
	save_data["player_team_data"] = _collect_player_team_data()
	
	# 收集世界地图数据
	save_data["world_map_data"] = _collect_world_map_data()
	
	# 收集世界事件数据
	save_data["world_events_data"] = _collect_world_events_data()
	
	# 收集游戏进度数据
	save_data["game_progress_data"] = _collect_game_progress_data()
	
	return save_data





# 收集玩家队伍数据
func _collect_player_team_data() -> Dictionary:
	var team_data = {}
	
	# 获取玩家队伍
	var player_team:BaseTeam = _find_player_team()
	if player_team:
		team_data["team_grid_position"] = player_team.get_serializable_data()
		# 收集队伍成员数据
		team_data["members"] = _collect_team_members_data()
	
	return team_data

# 查找玩家队伍
func _find_player_team() -> BaseTeam:
	# 首先尝试从GameState获取
	if GameState.baseteam_node != null:
		return GameState.baseteam_node
	
	# 如果GameState中没有，尝试从场景中查找
	var teams = get_tree().get_nodes_in_group("player_team")
	if not teams.is_empty():
		# 更新GameState中的引用
		GameState.baseteam_node = teams[0]
		return teams[0]
	
	# 如果还是找不到，尝试通过节点路径查找
	var player_team = get_tree().current_scene.get_node_or_null("PlayerTeam")
	if player_team and player_team is BaseTeam:
		GameState.baseteam_node = player_team
		return player_team
	
	push_warning("无法找到玩家队伍节点")
	return null

# 收集队伍成员数据
func _collect_team_members_data() -> Array[Dictionary]:
	var members_data:Array[Dictionary] = []
	var members:Array[UnitData] = GameState.player_characters
	for member:UnitData in members:
		if member.has_method("get_serializable_data"):
			var member_data = member.get_serializable_data()
			members_data.append(member_data)
	return members_data

# 收集世界地图数据
func _collect_world_map_data() -> Dictionary:
	var map_data = {}
	
	# 这里需要根据您的网格系统实现具体的收集逻辑
	# 示例：收集网格数据、探索区域等
	var grids:Dictionary[Vector2i,WorldGrid] = WorldGridManager.get_grid_data_dict()
	map_data["grids"] = grids
	
	return map_data

# 收集世界事件数据
func _collect_world_events_data() -> Dictionary:
	var events_data = {}
	
	# 这里需要根据您的事件系统实现具体的收集逻辑
	# 示例：收集活跃事件、已完成事件等
	
	return events_data

# 收集游戏进度数据
func _collect_game_progress_data() -> Dictionary:
	var progress_data = {}
	
	# 游戏时间
	progress_data["play_time"] = Time.get_ticks_msec() / 1000.0
	
	return progress_data

# 恢复游戏状态
func _restore_game_state() -> bool:
	if current_save_data == null:
		return false
	

	#关闭UI
	UiManager.close_all_open_ui()

	# 加载场景
	if current_save_data.has("current_scene_path"):
		var error = get_tree().change_scene_to_file(current_save_data["current_scene_path"])
		if error != OK:
			push_error("加载场景失败：" + current_save_data["current_scene_path"])
			return false
	
	# 等待场景加载完成
	#await get_tree().process_frame
	# await get_tree().scene_changed
	var scenes_name = await GameState.scenes_ready
	# print(scenes_name)
	# await get_tree().create_timer(1).timeout

	print("[WorldSaveManager] 场景加载完成，当前场景: ", get_tree().current_scene.name)

	var success = true
	success = success and _restore_world_map_data()# 恢复世界地图数据
	success = success and _restore_player_team_data()# 恢复玩家队伍数据
	
	success = success and _restore_world_events_data()# 恢复世界事件数据
	success = success and _restore_game_progress_data()# 恢复游戏进度数据
	
	return success

# 恢复玩家队伍数据
func _restore_player_team_data() -> bool:
	if not current_save_data.has("player_team_data"):
		return true
	
	var team_data:Dictionary = current_save_data["player_team_data"]
	
	# 查找玩家队伍
	var player_team = _find_player_team()
	
	if player_team == null:
		push_error("恢复队伍位置失败：找不到玩家队伍节点")
		return false
	
	if team_data.has("team_grid_position"):
		player_team.restore_from_data(team_data["team_grid_position"])


	# 恢复队伍成员
	if team_data.has("members"):
		var team_data_members = team_data["members"]
		if team_data_members is Array:
			# 确保数组中的每个元素都是字典
			var valid_members_data: Array[Dictionary] = []
			for member_data in team_data_members:
				if member_data is Dictionary:
					valid_members_data.append(member_data)
			
			if not valid_members_data.is_empty():
				# 恢复有效成员数据
				return _restore_team_members(valid_members_data)
			else:
				push_warning("队伍成员数据格式不正确，没有有效的字典数据")
		else:
			push_warning("队伍成员数据不是数组类型")
	return true
	

# 恢复队伍成员数据
func _restore_team_members(members_data: Array[Dictionary]) -> bool:
	if not members_data:
		return false
	var restored_count = 0

	#移除之前的队伍信息
	GameState.player_characters.clear()

	for member_data in members_data:
		var unit_data = UnitData.new()
		if unit_data.has_method("restore_from_data"):
			# 恢复角色数据,具体逻辑在 unit_data.restore_from_data()
			var success = unit_data.restore_from_data(member_data)
			if success:
				# 将恢复的UnitData添加到队伍中
				GameState.register_unit(unit_data)
				restored_count += 1
				# 这里需要根据您的队伍管理系统实现具体的添加逻辑
				print("[WorldSaveManager] 成功恢复角色数据: ", unit_data.character_name)
			else:
				push_warning("恢复角色数据失败: ", member_data.get("character_name", "未知角色"))
		else:
			push_error("UnitData类没有实现restore_from_data方法")
	print("[WorldSaveManager] 成功恢复 " + str(restored_count) + " 个队伍成员的数据")
	return restored_count > 0

# 恢复世界地图数据
func _restore_world_map_data() -> bool:
	if not current_save_data.has("world_map_data"):
		return true
	
	# 这里需要根据您的网格系统实现具体的恢复逻辑
	
	return true

# 恢复世界事件数据
func _restore_world_events_data() -> bool:
	if not current_save_data.has("world_events_data"):
		return true
	
	# 这里需要根据您的事件系统实现具体的恢复逻辑
	
	return true

# 恢复游戏进度数据
func _restore_game_progress_data() -> bool:
	if not current_save_data.has("game_progress_data"):
		return true
	
	# 这里需要根据您的进度系统实现具体的恢复逻辑
	
	return true

# 保存到文件
func _save_to_file(file_path: String, data: Dictionary) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("[WorldSaveManager] 世界存档已保存到：" + file_path)
		return true
	else:
		push_error("无法创建存档文件：" + file_path)
		return false

# 从文件加载
func _load_from_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return JSON.parse_string(content)
	else:
		push_error("无法读取存档文件：" + file_path)
		return {}





#--------------------世界初始化相关操作--------------------------
