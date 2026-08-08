extends Resource
class_name CharacterOverlayData

## 单个图像覆盖的数据：贴图、相对位置、缩放、贴图偏移、绘制层级。
## 层级从 0 开始，数字越大越靠上（0 在最底层）。

@export var overlay_id: String = ""
@export var texture: Texture2D
@export var position: Vector2 = Vector2.ZERO
@export var scale: Vector2 = Vector2.ONE
@export var offset: Vector2 = Vector2.ZERO
@export var layer: int = 0
@export var visible: bool = true

func to_save_data() -> Dictionary:
	return {
		"overlay_id": overlay_id,
		"texture_path": texture.resource_path if texture != null else "",
		"position": {"x": position.x, "y": position.y},
		"scale": {"x": scale.x, "y": scale.y},
		"offset": {"x": offset.x, "y": offset.y},
		"layer": layer,
		"visible": visible,
	}


func load_from_data(data: Dictionary) -> void:
	overlay_id = str(data.get("overlay_id", overlay_id))
	var texture_path := str(data.get("texture_path", ""))
	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		texture = load(texture_path)
	position = _parse_vector(data.get("position", {}), position)
	scale = _parse_vector(data.get("scale", {}), scale)
	offset = _parse_vector(data.get("offset", {}), offset)
	layer = int(data.get("layer", 0))
	visible = bool(data.get("visible", true))


func _parse_vector(raw: Variant, fallback: Vector2) -> Vector2:
	if raw is Dictionary:
		return Vector2(float(raw.get("x", fallback.x)), float(raw.get("y", fallback.y)))
	return fallback
