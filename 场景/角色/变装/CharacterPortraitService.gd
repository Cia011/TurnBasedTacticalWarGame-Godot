class_name CharacterPortraitService
## 角色最终形象合成服务：不依赖战斗场景里的 Unit 节点。
## 输入 UnitData，输出所有身体+装备图层叠加后的 Image / ImageTexture，
## 战斗单位与大地图角色卡片共用同一套合成逻辑。

const EQUIPMENT_SLOT_KEYS: Array[String] = ["主手", "副手", "盔甲", "头盔", "戒指", "项链", "道具"]


static func get_combined_image(unit_data: UnitData, extra_overlays: Array[CharacterOverlayData] = []) -> Image:
	var entries: Array[Dictionary] = []
	if unit_data == null:
		return Image.create(1, 1, false, Image.FORMAT_RGBA8)

	if unit_data.texture:
		entries.append(_prepare_image(
			unit_data.texture,
			unit_data.body_position,
			Vector2.ONE,
			unit_data.body_offset,
			-1
		))

	var body_center := unit_data.body_position + unit_data.body_offset
	for slot_key in EQUIPMENT_SLOT_KEYS:
		var item := unit_data.get_equipped_item(slot_key)
		if item == null or item.appearance_image == null:
			continue
		entries.append(_prepare_image(
			item.appearance_image,
			body_center + item.appearance_position,
			item.appearance_scale,
			item.appearance_offset,
			item.appearance_layer
		))

	for overlay in extra_overlays:
		if overlay == null or overlay.texture == null or not overlay.visible:
			continue
		entries.append(_prepare_image(
			overlay.texture,
			overlay.position,
			overlay.scale,
			overlay.offset,
			overlay.layer
		))

	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("layer", 0)) < int(b.get("layer", 0))
	)
	return _compose_entries(entries)


static func get_portrait_texture(unit_data: UnitData, target_size: Vector2i = Vector2i(64, 64)) -> ImageTexture:
	var image := get_combined_image(unit_data)
	if target_size.x > 0 and target_size.y > 0 and (image.get_width() != target_size.x or image.get_height() != target_size.y):
		image = image.duplicate()
		image.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)


static func _prepare_image(texture: Texture2D, position: Vector2, scale: Vector2, offset: Vector2, layer: int) -> Dictionary:
	var src := texture.get_image()
	if src == null:
		return {}
	var final_scale := scale
	if final_scale.x < 0.0:
		src = src.duplicate()
		src.flip_x()
		final_scale.x = -final_scale.x
	if final_scale.y < 0.0:
		src = src.duplicate()
		src.flip_y()
		final_scale.y = -final_scale.y
	if final_scale != Vector2.ONE:
		src = src.duplicate()
		src.resize(
			maxi(1, roundi(src.get_width() * final_scale.x)),
			maxi(1, roundi(src.get_height() * final_scale.y)),
			Image.INTERPOLATE_NEAREST
		)
	var top_left := position + offset - Vector2(src.get_width(), src.get_height()) * 0.5
	return {
		"image": src,
		"rect": Rect2(top_left, Vector2(src.get_width(), src.get_height())),
		"layer": layer,
	}


static func _compose_entries(entries: Array[Dictionary]) -> Image:
	var bounds := Rect2()
	var first := true
	for entry in entries:
		if entry.is_empty():
			continue
		var part_rect: Rect2 = entry["rect"]
		if first:
			bounds = part_rect
			first = false
		else:
			bounds = bounds.merge(part_rect)

	if entries.is_empty() or first:
		return Image.create(1, 1, false, Image.FORMAT_RGBA8)

	var canvas := Image.create(
		maxi(1, ceili(bounds.size.x)),
		maxi(1, ceili(bounds.size.y)),
		false,
		Image.FORMAT_RGBA8
	)
	canvas.fill(Color(0, 0, 0, 0))
	for entry in entries:
		if entry.is_empty():
			continue
		var src: Image = entry["image"]
		var dst := Vector2i((entry["rect"].position - bounds.position).floor())
		canvas.blit_rect(src, Rect2i(0, 0, src.get_width(), src.get_height()), dst)
	return canvas
