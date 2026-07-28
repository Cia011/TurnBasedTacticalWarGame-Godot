extends Control

# 战斗顺序UI - 显示所有角色的行动顺序及回合进度

@export var order_container: HBoxContainer
@export var info_label: Label
@export var turn_counter: Label
@export var unit_icon_scene: PackedScene

var _icon_map: Dictionary = {}  # Unit -> OrderUnitIcon
var _tween: Tween
var _turn_count: int = 1


func _ready():
	BattleTurnManager.signal_change_unit.connect(_on_unit_changed)
	BattleTurnManager.signal_turn_start.connect(_on_turn_start)
	BattleTurnManager.signal_turn_end.connect(_on_turn_end)

	BattleUnitManager.unit_registered.connect(_on_unit_registered)
	BattleUnitManager.unit_unregistered.connect(_on_unit_unregistered)

	call_deferred(&"_build_order")


# ---------------------------------------------------------------------------
#  初始化
# ---------------------------------------------------------------------------

func _build_order():
	if not order_container:
		return
	_clear_all_icons()

	var sorted = _get_sorted_units()
	for unit in sorted:
		_create_icon(unit)

	_update_all_progress()

	if BattleTurnManager.current_unit:
		_on_unit_changed(BattleTurnManager.current_unit)


func _get_sorted_units() -> Array:
	var all = BattleUnitManager.units.duplicate()
	all.sort_custom(func(a: Unit, b: Unit) -> bool:
		return a.unit_data.get_final_stat("agility") > b.unit_data.get_final_stat("agility")
	)
	return all


# ---------------------------------------------------------------------------
#  图标管理 — 先 add_child 再 set_up，确保 @onready 变量已解析
# ---------------------------------------------------------------------------

func _create_icon(unit: Unit):
	if _icon_map.has(unit):
		return

	var icon: OrderUnitIcon = unit_icon_scene.instantiate()
	icon.icon_clicked.connect(_on_icon_clicked)
	icon.modulate.a = 0.0

	_icon_map[unit] = icon
	order_container.add_child(icon)
	icon.set_up(unit)

	# 淡入动画
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(icon, "modulate:a", 1.0, 0.25)

	# 标记已经行动过的单位
	if BattleTurnManager.current_unit and unit != BattleTurnManager.current_unit:
		var val = BattleTurnManager.TurnManager.get(unit, 0.0)
		if val < 100.0:
			icon.set_acted(true)


func _clear_all_icons():
	for icon in _icon_map.values():
		if is_instance_valid(icon):
			icon.cleanup()
	_icon_map.clear()
	for child in order_container.get_children():
		if child is OrderUnitIcon:
			child.queue_free()


func _remove_icon(unit: Unit):
	if not _icon_map.has(unit):
		return
	var icon = _icon_map[unit]
	_icon_map.erase(unit)
	if is_instance_valid(icon):
		var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(icon, "modulate:a", 0.0, 0.2)
		t.tween_callback(icon.cleanup)


# ---------------------------------------------------------------------------
#  排序
# ---------------------------------------------------------------------------

func _resort_by_agility():
	if _icon_map.size() <= 1:
		return
	var sorted = _get_sorted_units().filter(func(u): return _icon_map.has(u))
	for i in range(sorted.size()):
		order_container.move_child(_icon_map[sorted[i]], i)


# ---------------------------------------------------------------------------
#  回合进度
# ---------------------------------------------------------------------------

func _update_all_progress():
	var tm = BattleTurnManager.TurnManager
	for unit in _icon_map:
		var val = tm.get(unit, 0.0)
		_icon_map[unit].set_turn_progress(clamp(val / 100.0, 0.0, 1.0))


# ---------------------------------------------------------------------------
#  信号处理
# ---------------------------------------------------------------------------

func _on_turn_start(unit: Unit):
	for u in _icon_map:
		if u != unit:
			_icon_map[u].set_acted(true)


func _on_turn_end(unit: Unit):
	if not _icon_map.has(unit):
		return
	var icon = _icon_map[unit]

	order_container.move_child(icon, order_container.get_child_count() - 1)

	icon.set_acted(false)
	icon.set_current(false)
	icon.set_turn_progress(1.0)

	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_method(_animate_turn_progress.bind(unit), 1.0, 0.0, 0.3)


func _animate_turn_progress(value: float, unit: Unit):
	if _icon_map.has(unit):
		_icon_map[unit].set_turn_progress(value)


func _on_unit_changed(unit: Unit):
	if not order_container:
		return

	for u in _icon_map:
		_icon_map[u].set_current(false)
		_icon_map[u].set_acted(false)

	if _icon_map.has(unit):
		var icon = _icon_map[unit]
		icon.set_current(true)

		var scroll = order_container.get_parent()
		if scroll is ScrollContainer:
			var icon_pos = icon.position.x
			var icon_end = icon_pos + icon.size.x
			var scroll_w = scroll.size.x
			var cur = scroll.scroll_horizontal
			if icon_pos < cur or icon_end > cur + scroll_w:
				scroll.ensure_control_visible(icon)

	if info_label:
		info_label.text = "%s 的回合" % unit.unit_data.character_name


# ---------------------------------------------------------------------------
#  单位注册 / 注销
# ---------------------------------------------------------------------------

func _on_unit_registered(unit: Unit):
	if not order_container:
		return
	_create_icon(unit)
	_resort_by_agility()
	if BattleTurnManager.current_unit:
		_on_unit_changed(BattleTurnManager.current_unit)


func _on_unit_unregistered(unit: Unit):
	_remove_icon(unit)


# ---------------------------------------------------------------------------
#  交互
# ---------------------------------------------------------------------------

func _on_icon_clicked(unit: Unit):
	print("BattleOrder: 点击 %s" % unit.unit_data.character_name)


# ---------------------------------------------------------------------------
#  外部接口
# ---------------------------------------------------------------------------

func refresh_order():
	_build_order()
	if BattleTurnManager.current_unit:
		_on_unit_changed(BattleTurnManager.current_unit)
	_update_all_progress()


func refresh_progress():
	_update_all_progress()


func _process(_delta: float):
	if not is_visible_in_tree():
		return
	var tm = BattleTurnManager.TurnManager
	for unit in _icon_map:
		_icon_map[unit].set_turn_progress(clamp(tm.get(unit, 0.0) / 100.0, 0.0, 1.0))
