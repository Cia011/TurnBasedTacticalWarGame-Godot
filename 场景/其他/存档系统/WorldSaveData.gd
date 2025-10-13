extends Resource
class_name WorldSaveData

# 存档元数据
var timestamp: int = 0
var version: String = "1.0.0"

# 场景信息
var current_scene_path: String = ""
var current_scene_name: String = ""

# 玩家队伍数据
var player_team_data: Dictionary = {}

# 世界地图数据
var world_map_data: Dictionary = {}

# 世界事件数据
var world_events_data: Dictionary = {}

# 游戏进度数据
var game_progress_data: Dictionary = {}

# 序列化数据
func serialize() -> Dictionary:
	return {
		"timestamp": timestamp,
		"version": version,
		"current_scene_path": current_scene_path,
		"current_scene_name": current_scene_name,
		"player_team_data": player_team_data,
		"world_map_data": world_map_data,
		"world_events_data": world_events_data,
		"game_progress_data": game_progress_data
	}

# 反序列化数据
func deserialize(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	
	timestamp = data.get("timestamp", 0)
	version = data.get("version", "1.0.0")
	current_scene_path = data.get("current_scene_path", "")
	current_scene_name = data.get("current_scene_name", "")
	player_team_data = data.get("player_team_data", {})
	world_map_data = data.get("world_map_data", {})
	world_events_data = data.get("world_events_data", {})
	game_progress_data = data.get("game_progress_data", {})
	
	return true
