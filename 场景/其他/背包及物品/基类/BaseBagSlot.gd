extends TextureRect
class_name BaseBagSlot
@onready var 物品图标: TextureRect = $物品图标
@onready var 数量显示: Label = $数量显示
@onready var 高亮: ColorRect = $高亮

@export var is_usable : bool = true
@export var slot_type : String = "任意"
@export var default_icon : Texture2D
func _ready() -> void:
	if ! is_usable:
		物品图标.visible = false
		高亮.visible = true
		#高亮.color = 
		
func is_highlight()->bool:
	return 高亮.visible

func set_highlight(BOOL:bool):
	高亮.visible = BOOL

func set_item(item:BaseItem):
	if item != null:
		物品图标.texture = item.texture
		if item.max_stack > 1:
			数量显示.text = str(item.number)
		else:数量显示.text = ""
	else:
		if default_icon != null:
			物品图标.texture = default_icon
			数量显示.text = ""
		else:
			物品图标.texture = null
			数量显示.text = ""
