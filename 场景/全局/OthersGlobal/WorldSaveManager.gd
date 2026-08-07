extends Node
## 世界地图存档管理器（自动加载：WorldSaveManager）
## 大地图可以存档/读档，战斗地图不存档。
## 保存：金币、角色状态、buff、角色装备、背包、事件、大地图地块、队伍位置、商店状态。
## 扩展：在 _collect_save_data / _apply_save_data 中追加新模块即可。

const SAVE_VERSION := 1
const SAVE_PATH := "user://save_game.json"


func save_game() -> bool:
	var data := _collect_save_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[WorldSaveManager] 无法写入存档：%s" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	GBIS.save()
	print("[WorldSaveManager] 存档完成")
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		push_warning("[WorldSaveManager] 没有找到存档：%s" % SAVE_PATH)
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		push_error("[WorldSaveManager] 存档解析失败")
		return false
	await get_tree().process_frame
	_apply_save_data(parsed)
	await GBIS.load()
	print("[WorldSaveManager] 读档完成")
	return true


## 收集所有需要保存的数据
func _collect_save_data() -> Dictionary:
	var data := {
		"version": SAVE_VERSION,
		"money": PartyWallet.money,
		"players": [],
		"events": WorldEventManager.serialize(),
		"shops": ShopManager.serialize(),
	}
	for unit in GameState.player_characters:
		data["players"].append(unit.serialize())
	if WorldGridManager.data_layer and WorldGridManager.data_layer.has_method("serialize"):
		data["map"] = WorldGridManager.data_layer.serialize()
	if GameState.baseteam_node and GameState.baseteam_node.has_method("serialize"):
		data["team"] = GameState.baseteam_node.serialize()
	return data


## 把存档数据写回运行时状态
func _apply_save_data(data: Dictionary) -> void:
	PartyWallet.money = int(data.get("money", 500))

	var players: Array = data.get("players", [])
	for i in mini(players.size(), GameState.player_characters.size()):
		GameState.player_characters[i].deserialize(players[i])

	if data.has("map") and WorldGridManager.data_layer and WorldGridManager.data_layer.has_method("deserialize"):
		WorldGridManager.data_layer.deserialize(data["map"])
	if data.has("team") and GameState.baseteam_node and GameState.baseteam_node.has_method("deserialize"):
		GameState.baseteam_node.deserialize(data["team"])
	if data.has("events"):
		WorldEventManager.deserialize(data["events"])
	if data.has("shops"):
		ShopManager.deserialize(data["shops"])


## 存档数据是否存在
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
