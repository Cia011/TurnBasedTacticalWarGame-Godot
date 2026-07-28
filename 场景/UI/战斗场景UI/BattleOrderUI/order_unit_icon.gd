extends PanelContainer
class_name OrderUnitIcon

# 战斗顺序中的单位图标组件
signal icon_clicked(unit: Unit)

var unit: Unit = null
var is_current: bool = false
var is_acted: bool = false

@onready var avatar_rect: TextureRect = $VBox/FrameHighlight/CenterContainer/AvatarRect
@onready var name_label: Label = $VBox/NameLabel
@onready var turn_meter: ProgressBar = $VBox/TurnMeter
@onready var hp_bar: ProgressBar = $VBox/HPBar
@onready var frame_highlight: PanelContainer = $VBox/FrameHighlight

func set_up(target_unit: Unit):
	unit = target_unit
	name = "Icon_%s" % unit.unit_data.character_name

	# 设置头像
	if unit.unit_data.texture:
		avatar_rect.texture = unit.unit_data.texture
	else:
		_draw_default_avatar()

	# 设置名称
	name_label.text = unit.unit_data.character_name

	# 设置阵营颜色
	var team_color = Color(0.35, 0.6, 0.9) if unit.is_teammate else Color(0.85, 0.3, 0.3)
	var bg_color = Color(0.2, 0.35, 0.55) if unit.is_teammate else Color(0.45, 0.15, 0.15)
	_apply_team_style(team_color, bg_color)

	# 初始状态
	set_current(false)
	set_acted(false)

	# 连接单位数据变化信号
	if unit.unit_data.data_manager:
		unit.unit_data.data_manager.stat_changed.connect(_on_unit_data_changed)
	unit.current_action_points_changed.connect(_on_action_points_changed)

	_update_hp()


func _draw_default_avatar():
	var size = 48
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var bg = Color(0.25, 0.25, 0.3)
	img.fill(bg)
	var letter = unit.unit_data.character_name.left(1)
	for y in range(size):
		for x in range(size):
			var border = x < 2 or x >= size - 2 or y < 2 or y >= size - 2
			var c = Color(0.6, 0.6, 0.6) if border else bg
			img.set_pixel(x, y, c)
	avatar_rect.texture = ImageTexture.create_from_image(img)


func _apply_team_style(team_color: Color, bg_color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = team_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	add_theme_stylebox_override("panel", style)


func set_current(value: bool):
	is_current = value
	frame_highlight.modulate.a = 1.0 if value else 0.0
	scale = Vector2(1.15, 1.15) if value else Vector2(1.0, 1.0)


func set_acted(value: bool):
	is_acted = value
	modulate.a = 0.5 if value else 1.0


func set_turn_progress(progress: float):
	turn_meter.value = clamp(progress, 0.0, 1.0)


func _update_hp():
	if not unit:
		return
	var max_hp = unit.get_stat("max_health")
	var current_hp = unit.get_stat("current_health")
	if max_hp > 0:
		hp_bar.max_value = max_hp
		hp_bar.value = max(0, current_hp)
		var ratio = float(current_hp) / float(max_hp)
		if ratio > 0.6:
			hp_bar.modulate = Color(0.3, 0.85, 0.3)
		elif ratio > 0.3:
			hp_bar.modulate = Color(0.85, 0.75, 0.2)
		else:
			hp_bar.modulate = Color(0.85, 0.25, 0.2)


func _on_unit_data_changed(new_stats: Dictionary):
	_update_hp()


func _on_action_points_changed(new_value: int):
	pass


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if unit:
			icon_clicked.emit(unit)


func cleanup():
	if unit and unit.unit_data.data_manager:
		if unit.unit_data.data_manager.stat_changed.is_connected(_on_unit_data_changed):
			unit.unit_data.data_manager.stat_changed.disconnect(_on_unit_data_changed)
	if unit and unit.current_action_points_changed.is_connected(_on_action_points_changed):
		unit.current_action_points_changed.disconnect(_on_action_points_changed)
	unit = null
	queue_free()
