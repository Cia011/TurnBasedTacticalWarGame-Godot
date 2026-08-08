extends Node
## 游戏物品数据库（自动加载：GameItemDatabase）
## 自动读取 数据/物品/*.json 创建装备与物品，并提供序列化/反序列化供存档使用。

const ITEM_DIR := "res://数据/物品"
const TEAM_INVENTORY := "TeamInventory"

const ITEM_CLASS_SCRIPTS := {
	"BaseItemData": "res://场景/背包系统/物品/BaseItemData.gd",
	"BaseStackableItemData": "res://场景/背包系统/物品/BaseStackableItemData.gd",
	"BaseConsumableItemData": "res://场景/背包系统/物品/BaseConsumableItemData.gd",
	"FoodItemData": "res://场景/背包系统/物品/FoodItemData.gd",
	"PotionItemData": "res://场景/背包系统/物品/PotionItemData.gd",
	"TradeGoodsItemData": "res://场景/背包系统/物品/TradeGoodsItemData.gd",
	"BaseEquipmentItemData": "res://场景/背包系统/物品/装备/BaseEquipmentItemData.gd",
	"WeaponItemData": "res://场景/背包系统/物品/装备/WeaponItemData.gd",
	"ArmorItemData": "res://场景/背包系统/物品/装备/ArmorItemData.gd",
	"HelmetItemData": "res://场景/背包系统/物品/装备/HelmetItemData.gd",
	"RingItemData": "res://场景/背包系统/物品/装备/RingItemData.gd",
	"NecklaceItemData": "res://场景/背包系统/物品/装备/NecklaceItemData.gd",
	"TrinketItemData": "res://场景/背包系统/物品/装备/TrinketItemData.gd",
}

## id -> ItemData 模板
var item_templates: Dictionary = {}


func _ready() -> void:
	GBIS.inventory_service.regist(TEAM_INVENTORY, 8, 5, false, ["ANY"])
	_load_json_items()
	_build_shops()
	_seed_inventory()


## 读取 数据/物品 下所有 JSON 文件并创建物品
func _load_json_items() -> void:
	var dir := DirAccess.open(ITEM_DIR)
	if dir == null:
		push_error("[GameItemDatabase] 无法打开物品目录：%s" % ITEM_DIR)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			_load_json_file("%s/%s" % [ITEM_DIR, file_name])
		file_name = dir.get_next()
	dir.list_dir_end()


func _load_json_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[GameItemDatabase] 无法读取物品文件：%s" % path)
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Array:
		_register_items_from_array(parsed)
	elif parsed is Dictionary and parsed.get("items") is Array:
		_register_items_from_array(parsed["items"])
	else:
		push_warning("[GameItemDatabase] 物品文件格式不正确：%s" % path)


func _register_items_from_array(array: Array) -> void:
	for raw in array:
		if not (raw is Dictionary):
			continue
		var item := create_item_from_data(raw)
		if item == null:
			continue
		var item_id := str(raw.get("id", item.item_name))
		item.set_meta("item_id", item_id)
		item_templates[item_id] = item


## 从字典创建一个物品实例（同时供存档反序列化使用）
func create_item_from_data(data: Dictionary) -> ItemData:
	var class_name_str := str(data.get("class", ""))
	var script_path: String = ITEM_CLASS_SCRIPTS.get(class_name_str, "")
	if script_path.is_empty():
		push_error("[GameItemDatabase] 未知物品类：%s" % class_name_str)
		return null
	var script: GDScript = load(script_path)
	if script == null:
		push_error("[GameItemDatabase] 无法加载物品脚本：%s" % script_path)
		return null
	var item: ItemData = script.new()
	if item == null:
		return null

	item.item_name = str(data.get("item_name", item.item_name))
	item.type = str(data.get("type", item.type))
	item.columns = int(data.get("columns", item.columns))
	item.rows = int(data.get("rows", item.rows))
	item.icon = _load_texture(data.get("icon", ""), item.icon)

	for key in ["price", "sell_ratio", "description", "weight"]:
		if data.has(key):
			item.set(key, data[key])

	if item.get("stack_size") != null:
		item.set("stack_size", int(data.get("stack_size", item.get("stack_size"))))
	if item.get("current_amount") != null:
		item.set("current_amount", int(data.get("current_amount", item.get("current_amount"))))
	if item.get("heal_amount") != null:
		item.set("heal_amount", int(data.get("heal_amount", item.get("heal_amount"))))

	if item is BaseEquipmentItemData:
		_apply_equipment_fields(item as BaseEquipmentItemData, data)
	return item


func _apply_equipment_fields(item: BaseEquipmentItemData, data: Dictionary) -> void:
	item.compatible_slots = _to_string_array(data.get("compatible_slots", item.compatible_slots))
	var bonuses: Variant = data.get("stat_bonuses", item.stat_bonuses)
	item.stat_bonuses = bonuses if bonuses is Dictionary else {}
	item.appearance_image = _load_texture(data.get("appearance_image", ""), item.appearance_image)
	item.appearance_slot = str(data.get("appearance_slot", item.appearance_slot))
	item.appearance_layer = int(data.get("appearance_layer", 0))
	item.appearance_position = _parse_vector2(data.get("appearance_position", {}), item.appearance_position)
	item.appearance_scale = _parse_vector2(data.get("appearance_scale", {}), item.appearance_scale)
	item.appearance_offset = _parse_vector2(data.get("appearance_offset", {}), item.appearance_offset)
	item.animations = _parse_animations(data.get("animations", {}))


func _load_texture(raw_path: Variant, fallback: Texture2D) -> Texture2D:
	var path := str(raw_path)
	if path.is_empty():
		return fallback
	if ResourceLoader.exists(path):
		return load(path)
	return fallback


func _parse_vector2(raw: Variant, fallback: Vector2) -> Vector2:
	if raw is Dictionary:
		return Vector2(float(raw.get("x", fallback.x)), float(raw.get("y", fallback.y)))
	return fallback


func _to_string_array(raw: Variant) -> Array[String]:
	var result: Array[String] = []
	if raw is Array:
		for value in raw:
			result.append(str(value))
	return result


## 解析 JSON 中的动画定义，统一成运行时格式
func _parse_animations(raw: Variant) -> Dictionary:
	var result := {}
	if not (raw is Dictionary):
		return result
	for anim_name in raw:
		var parsed := _parse_animation(raw[anim_name])
		if not parsed.is_empty():
			result[str(anim_name)] = parsed
	return result


func _parse_animation(raw: Variant) -> Dictionary:
	if raw is Array:
		return _build_animation("", false, true, "cubic", "out", raw, 0.0)
	if not (raw is Dictionary):
		return {}
	var keys_raw: Variant = raw.get("keys", [])
	if not (keys_raw is Array):
		keys_raw = [raw]
	return _build_animation(
		str(raw.get("target", "")),
		bool(raw.get("loop", false)),
		bool(raw.get("restore", true)),
		str(raw.get("transition", "cubic")),
		str(raw.get("ease", "out")),
		keys_raw,
		float(raw.get("duration", 0.0))
	)


func _build_animation(target: String, loop: bool, restore: bool, transition: String, ease: String, keys_raw: Array, explicit_duration: float) -> Dictionary:
	var keys: Array = []
	var duration := 0.0
	for key_raw in keys_raw:
		if not (key_raw is Dictionary):
			continue
		var key := {"time": float(key_raw.get("time", 0.0))}
		if key_raw.has("position") and key_raw["position"] is Dictionary:
			key["position"] = _parse_vector2(key_raw["position"], Vector2.ZERO)
		if key_raw.has("scale") and key_raw["scale"] is Dictionary:
			key["scale"] = _parse_vector2(key_raw["scale"], Vector2.ONE)
		if key_raw.has("rotation"):
			key["rotation"] = float(key_raw["rotation"])
		keys.append(key)
		duration = maxf(duration, float(key["time"]))
	if explicit_duration > 0.0:
		duration = explicit_duration
	return {
		"target": target,
		"duration": duration,
		"loop": loop,
		"restore": restore,
		"transition": transition,
		"ease": ease,
		"keys": keys,
	}


func _serialize_animations(animations: Dictionary) -> Dictionary:
	var result := {}
	for anim_name in animations:
		var anim: Dictionary = animations[anim_name]
		var keys: Array = []
		for key in anim.get("keys", []):
			var out := {"time": float(key.get("time", 0.0))}
			if key.has("position"):
				var pos: Vector2 = key["position"]
				out["position"] = {"x": pos.x, "y": pos.y}
			if key.has("scale"):
				var scale: Vector2 = key["scale"]
				out["scale"] = {"x": scale.x, "y": scale.y}
			if key.has("rotation"):
				out["rotation"] = float(key["rotation"])
			keys.append(out)
		result[str(anim_name)] = {
			"target": str(anim.get("target", "")),
			"duration": float(anim.get("duration", 0.0)),
			"loop": bool(anim.get("loop", false)),
			"restore": bool(anim.get("restore", true)),
			"transition": str(anim.get("transition", "cubic")),
			"ease": str(anim.get("ease", "out")),
			"keys": keys,
		}
	return result


## 把物品序列化为可写入 JSON 存档的字典
func serialize_item(item: ItemData) -> Dictionary:
	var data := {}
	data["item_name"] = item.item_name
	data["type"] = item.type
	data["columns"] = item.columns
	data["rows"] = item.rows
	if item.icon and not item.icon.resource_path.is_empty():
		data["icon"] = item.icon.resource_path
	var script := item.get_script() as GDScript
	data["class"] = script.get_global_name() if script and not script.get_global_name().is_empty() else item.get_class()
	var id_meta: Variant = item.get_meta("item_id", "")
	if not str(id_meta).is_empty():
		data["id"] = str(id_meta)

	for key in ["price", "sell_ratio", "description", "weight"]:
		var value: Variant = item.get(key)
		if value != null:
			data[key] = value

	if item.get("stack_size") != null:
		data["stack_size"] = item.get("stack_size")
		data["current_amount"] = item.get("current_amount")
	if item.get("heal_amount") != null:
		data["heal_amount"] = item.get("heal_amount")

	if item is BaseEquipmentItemData:
		var eq := item as BaseEquipmentItemData
		data["compatible_slots"] = eq.compatible_slots.duplicate()
		data["stat_bonuses"] = eq.stat_bonuses.duplicate()
		if eq.appearance_image and not eq.appearance_image.resource_path.is_empty():
			data["appearance_image"] = eq.appearance_image.resource_path
		data["appearance_slot"] = eq.appearance_slot
		data["appearance_layer"] = eq.appearance_layer
		data["appearance_position"] = {"x": eq.appearance_position.x, "y": eq.appearance_position.y}
		data["appearance_scale"] = {"x": eq.appearance_scale.x, "y": eq.appearance_scale.y}
		data["appearance_offset"] = {"x": eq.appearance_offset.x, "y": eq.appearance_offset.y}
		data["animations"] = _serialize_animations(eq.animations)
	return data


func deserialize_item(data: Dictionary) -> ItemData:
	return create_item_from_data(data)


## 获取物品模板的新副本（避免多个容器共享同一个 Resource）
func get_item(id: String) -> ItemData:
	if not item_templates.has(id):
		push_warning("[GameItemDatabase] 没有找到物品：%s" % id)
		return null
	return item_templates[id].duplicate(true)


func has_item(id: String) -> bool:
	return item_templates.has(id)


func get_item_id(item_name: String) -> String:
	for item_id in item_templates:
		if item_templates[item_id].item_name == item_name:
			return item_id
	return ""


## 兼容旧代码的快捷创建方法
func make_iron_sword() -> WeaponItemData:
	return get_item("iron_sword") as WeaponItemData


func make_iron_shield() -> WeaponItemData:
	return get_item("iron_shield") as WeaponItemData


func make_leather_armor() -> ArmorItemData:
	return get_item("leather_armor") as ArmorItemData


func make_iron_armor() -> ArmorItemData:
	return get_item("iron_armor") as ArmorItemData


func make_iron_helmet() -> HelmetItemData:
	return get_item("iron_helmet") as HelmetItemData


func make_silver_ring() -> RingItemData:
	return get_item("silver_ring") as RingItemData


func make_pendant() -> NecklaceItemData:
	return get_item("pendant") as NecklaceItemData


func make_war_belt() -> TrinketItemData:
	return get_item("war_belt") as TrinketItemData


func make_bread() -> FoodItemData:
	return get_item("bread") as FoodItemData


func make_dried_meat() -> FoodItemData:
	return get_item("dried_meat") as FoodItemData


func make_health_potion() -> PotionItemData:
	return get_item("health_potion") as PotionItemData


func make_cloth() -> TradeGoodsItemData:
	return get_item("cloth") as TradeGoodsItemData


func make_herb() -> TradeGoodsItemData:
	return get_item("herb") as TradeGoodsItemData


func _build_shops() -> void:
	ShopManager.register_shop("杂货铺", [
		get_item("bread"),
		get_item("dried_meat"),
		get_item("health_potion"),
		get_item("cloth"),
		get_item("herb"),
		get_item("war_belt"),
	], 6, 4, {"tier": 1, "funds": 300})

	ShopManager.register_shop("武器店", [
		get_item("iron_sword"),
		get_item("iron_shield"),
		get_item("iron_sword"),
	], 4, 3, {"tier": 2, "funds": 800})

	ShopManager.register_shop("防具店", [
		get_item("leather_armor"),
		get_item("iron_armor"),
		get_item("iron_helmet"),
		get_item("war_belt"),
	], 5, 3, {"tier": 2, "funds": 700})

	ShopManager.register_shop("饰品店", [
		get_item("silver_ring"),
		get_item("pendant"),
		get_item("silver_ring"),
		get_item("pendant"),
	], 4, 2, {"tier": 3, "funds": 1200})


func _seed_inventory() -> void:
	GBIS.add_item(TEAM_INVENTORY, get_item("bread"))
	GBIS.add_item(TEAM_INVENTORY, get_item("dried_meat"))
	GBIS.add_item(TEAM_INVENTORY, get_item("health_potion"))
	GBIS.add_item(TEAM_INVENTORY, get_item("cloth"))
	GBIS.add_item(TEAM_INVENTORY, get_item("herb"))
	GBIS.add_item(TEAM_INVENTORY, get_item("iron_sword"))
	GBIS.add_item(TEAM_INVENTORY, get_item("iron_shield"))
	GBIS.add_item(TEAM_INVENTORY, get_item("leather_armor"))
	GBIS.add_item(TEAM_INVENTORY, get_item("iron_helmet"))
	GBIS.add_item(TEAM_INVENTORY, get_item("silver_ring"))
	GBIS.add_item(TEAM_INVENTORY, get_item("pendant"))
	GBIS.add_item(TEAM_INVENTORY, get_item("war_belt"))
