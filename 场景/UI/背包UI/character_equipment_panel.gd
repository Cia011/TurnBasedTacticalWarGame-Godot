extends Control
## 角色装备栏（参考战场兄弟布局）
## 位置：头盔(头)、项链(颈)、主手(左)、盔甲(身)、副手(右)、戒指(手)、道具(下)
class_name CharacterEquipmentPanel

const SLOT_KEY_BY_NODE_NAME := {
	"slot_helmet": "头盔",
	"slot_necklace": "项链",
	"slot_mainhand": "主手",
	"slot_armor": "盔甲",
	"slot_offhand": "副手",
	"slot_ring": "戒指",
	"slot_trinket": "道具",
}

var unit_data: UnitData
var _slot_views: Array[EquipmentSlotView] = []

@onready var title_label: Label = $TitleLabel
@onready var background: Panel = $Background

func set_unit(unit_data: UnitData) -> void:
	_clear_slots()
	self.unit_data = unit_data
	if title_label:
		title_label.text = "%s 装备" % unit_data.character_name
	_bind_slots()

func _clear_slots() -> void:
	# 槽位节点在场景中静态摆放，切换角色时只需清空引用
	_slot_views.clear()

func _bind_slots() -> void:
	if unit_data == null:
		return
	var char_id := unit_data.get_character_id()
	for child in get_children():
		if not (child is EquipmentSlotView):
			continue
		var slot_key: String = SLOT_KEY_BY_NODE_NAME.get(child.name, "")
		if slot_key.is_empty():
			continue
		child.slot_name = "%s_%s" % [char_id, slot_key]
		GBIS.equipment_slot_service.regist_slot(child.slot_name, child.avilable_types)
		child.refresh()
		_slot_views.append(child)
	print("[背包UI] %s 装备槽绑定完成：%d 个" % [unit_data.character_name, _slot_views.size()])
