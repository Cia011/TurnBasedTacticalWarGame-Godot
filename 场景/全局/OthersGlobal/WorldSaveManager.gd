extends Node
## 世界地图多存档管理器（自动加载：WorldSaveManager）
## 存档目录为 user://saves/，每个存档是一个独立 JSON 文件。
## 保存：金币、角色状态、buff、角色装备、背包、事件、大地图地块、队伍位置、商店状态。
## 存档列表按修改时间倒序排列，UI 通过 get_saves() 读取。

const SAVE_VERSION := 2
const SAVE_DIR := "user://saves"
const SAVE_EXT := ".json"

## 可存档组件：实现 get_save_data() / apply_save_data(data) 后注册，即可自动进出存档
var savables: Array[Node] = []


func _ready() -> void:
	call_deferred("_register_default_savables")


func _register_default_savables() -> void:
	register_savable(PartyWallet)
	register_savable(WorldEventManager)
	register_savable(ShopManager)


func register_savable(node: Node) -> void:
	if node and not savables.has(node):
		savables.append(node)


func unregister_savable(node: Node) -> void:
	savables.erase(node)


## 保存新存档；save_name 为空时使用"未命名存档"，save_file 指定时覆盖该存档
func save_game(save_name: String = "", save_file: String = "") -> String:
	_ensure_save_dir()
	var target_path := save_file
	if target_path.is_empty():
		target_path = _generate_save_path(save_name)
	var now := Time.get_unix_time_from_system()
	var created_at := float(now)
	if FileAccess.file_exists(target_path):
		var old_meta := _read_save_meta(target_path)
		created_at = float(old_meta.get("created_at", now))
	var data := _collect_save_data(save_name, created_at, now)
	var file := FileAccess.open(target_path, FileAccess.WRITE)
	if file == null:
		push_error("[WorldSaveManager] 无法写入存档：%s" % target_path)
		return ""
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("[WorldSaveManager] 存档完成：%s" % target_path)
	return target_path


## 读取存档；save_file 为空时读取最近修改的存档
func load_game(save_file: String = "") -> bool:
	var target_path := save_file
	if target_path.is_empty():
		var saves := get_saves()
		if saves.is_empty():
			push_warning("[WorldSaveManager] 没有找到任何存档")
			return false
		target_path = str(saves[0]["path"])
	if not FileAccess.file_exists(target_path):
		push_warning("[WorldSaveManager] 没有找到存档：%s" % target_path)
		return false
	var file := FileAccess.open(target_path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		push_error("[WorldSaveManager] 存档解析失败：%s" % target_path)
		return false
	await get_tree().process_frame
	_apply_save_data(parsed)
	print("[WorldSaveManager] 读档完成：%s" % target_path)
	return true


## 扫描存档目录，按修改时间倒序返回存档元信息
func get_saves() -> Array[Dictionary]:
	_ensure_save_dir()
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return []
	var saves: Array[Dictionary] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(SAVE_EXT):
			var meta := _read_save_meta("%s/%s" % [SAVE_DIR, file_name])
			if not meta.is_empty():
				saves.append(meta)
		file_name = dir.get_next()
	dir.list_dir_end()
	saves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("modified_at", 0.0)) > float(b.get("modified_at", 0.0))
	)
	return saves


func has_save() -> bool:
	return not get_saves().is_empty()


func delete_save(save_path: String) -> bool:
	if save_path.is_empty() or not FileAccess.file_exists(save_path):
		return false
	var global_path := ProjectSettings.globalize_path(save_path)
	return DirAccess.remove_absolute(global_path) == OK


func get_save_dir() -> String:
	return SAVE_DIR


## 读取存档文件里的元信息（不解析完整存档）
func _read_save_meta(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return {}
	return {
		"path": path,
		"file_name": path.get_file(),
		"save_name": str(parsed.get("save_name", "未命名存档")),
		"created_at": float(parsed.get("created_at", 0.0)),
		"modified_at": float(parsed.get("modified_at", 0.0)),
		"version": int(parsed.get("version", 0)),
	}


func _ensure_save_dir() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))


func _generate_save_path(save_name: String) -> String:
	var stamp := Time.get_datetime_string_from_system(false, true)
	stamp = stamp.replace(":", "-").replace(" ", "-").replace("T", "_")
	var base := "%s/save_%s_%s" % [SAVE_DIR, _sanitize_name(save_name), stamp]
	var path := base + SAVE_EXT
	var index := 2
	while FileAccess.file_exists(path):
		path = "%s_%d%s" % [base, index, SAVE_EXT]
		index += 1
	return path


func _sanitize_name(name: String) -> String:
	var cleaned := name.strip_edges()
	if cleaned.is_empty():
		cleaned = "未命名存档"
	var invalid := "\\/:*?\"<>|"
	var result := ""
	for char in cleaned:
		result += "_" if invalid.contains(char) else char
	return result


## 收集所有需要保存的数据
func _collect_save_data(save_name: String, created_at: float, modified_at: float) -> Dictionary:
	var data := {
		"version": SAVE_VERSION,
		"save_name": _sanitize_name(save_name),
		"created_at": created_at,
		"modified_at": modified_at,
		"players": [],
		"custom": {},
		"inventory": _collect_inventory_data(),
	}
	for unit in GameState.player_characters:
		data["players"].append(unit.serialize())
	if WorldGridManager.data_layer and WorldGridManager.data_layer.has_method("serialize"):
		data["map"] = WorldGridManager.data_layer.serialize()
	if GameState.baseteam_node and GameState.baseteam_node.has_method("serialize"):
		data["team"] = GameState.baseteam_node.serialize()
	for node in savables:
		if node and node.has_method("get_save_data"):
			data["custom"][node.name] = node.get_save_data()
	return data


## 把存档数据写回运行时状态
func _apply_save_data(data: Dictionary) -> void:
	var players: Array = data.get("players", [])
	for i in mini(players.size(), GameState.player_characters.size()):
		GameState.player_characters[i].deserialize(players[i])

	_restore_inventory_data(data.get("inventory", {}))

	if data.has("map") and WorldGridManager.data_layer and WorldGridManager.data_layer.has_method("deserialize"):
		WorldGridManager.data_layer.deserialize(data["map"])
	if data.has("team") and GameState.baseteam_node and GameState.baseteam_node.has_method("deserialize"):
		GameState.baseteam_node.deserialize(data["team"])
	var custom: Dictionary = data.get("custom", {})
	for node in savables:
		if node and custom.has(node.name) and node.has_method("apply_save_data"):
			node.apply_save_data(custom[node.name])

	GBIS.sig_inv_refresh.emit()
	GBIS.sig_slot_refresh.emit()
	GBIS.sig_shop_refresh.emit()


func _collect_inventory_data() -> Dictionary:
	var containers := {}
	for container_name in GBIS.inventory_names:
		var container := GBIS.inventory_service.get_container(container_name)
		if container == null:
			continue
		var items_data: Array = []
		for entry in container.get_item_entries():
			items_data.append({
				"item": GameItemDatabase.serialize_item(entry["item"]),
				"grids": _serialize_grids(entry["grids"]),
			})
		containers[container_name] = {
			"columns": container.columns,
			"rows": container.rows,
			"avilable_types": container.avilable_types.duplicate(),
			"items": items_data,
		}

	var slots := {}
	var all_slots := GBIS.equipment_slot_service.get_all_slots()
	for slot_name in all_slots:
		var slot: EquipmentSlotData = all_slots[slot_name]
		var equipped_data: Variant = null
		if slot.equipped_item:
			equipped_data = GameItemDatabase.serialize_item(slot.equipped_item)
		slots[slot_name] = {
			"avilable_types": slot.avilable_types.duplicate(),
			"equipped_item": equipped_data,
		}

	return {
		"containers": containers,
		"quick_move_relations": GBIS.inventory_service.get_quick_move_relations_map(),
		"slots": slots,
	}


func _restore_inventory_data(data: Dictionary) -> void:
	GBIS.inventory_service.clear_all_containers()
	var containers: Dictionary = data.get("containers", {})
	for container_name in containers:
		var def: Dictionary = containers[container_name]
		var types := _to_string_array(def.get("avilable_types", ["ANY"]))
		var container := GBIS.inventory_service.regist(
			str(container_name),
			int(def.get("columns", 8)),
			int(def.get("rows", 5)),
			false,
			types
		)
		if container == null:
			continue
		for entry in def.get("items", []):
			if not (entry is Dictionary):
				continue
			var item_data := GameItemDatabase.deserialize_item(entry.get("item", {}))
			if item_data == null:
				continue
			container.restore_item(item_data, _parse_grids(entry.get("grids", [])))

	GBIS.inventory_service.restore_quick_move_relations(data.get("quick_move_relations", {}))

	GBIS.equipment_slot_service.clear_all_slots()
	var slots: Dictionary = data.get("slots", {})
	for slot_name in slots:
		var def: Dictionary = slots[slot_name]
		var item_data: ItemData = null
		var equipped_raw: Variant = def.get("equipped_item", null)
		if equipped_raw is Dictionary:
			item_data = GameItemDatabase.deserialize_item(equipped_raw)
		GBIS.equipment_slot_service.restore_slot(
			str(slot_name),
			_to_string_array(def.get("avilable_types", [])),
			item_data
		)


func _serialize_grids(grids: Array) -> Array:
	var result: Array = []
	for grid in grids:
		if grid is Vector2i:
			result.append({"x": grid.x, "y": grid.y})
	return result


func _parse_grids(raw: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for entry in raw:
		if entry is Dictionary:
			result.append(Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0))))
	return result


func _to_string_array(raw: Variant) -> Array[String]:
	var result: Array[String] = []
	if raw is Array:
		for value in raw:
			result.append(str(value))
	return result
