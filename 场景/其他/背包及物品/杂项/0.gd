extends Node2D
@onready var 物品图标: TextureRect = $物品图标
@onready var 数量显示: Label = $数量显示
@onready var 高亮: ColorRect = $高亮

var item:BaseItem = null


func is_highlight()->bool:
	return 高亮.visible

func set_highlight(BOOL:bool):
	高亮.visible = BOOL

func set_item(item:BaseItem):
	if item != null:
		物品图标.texture = item.texture
		self.item = item
		if item.max_stack > 1:
			数量显示.text = str(item.number)
		else:数量显示.text = ""
	else:
		self.item = null
		物品图标.texture = null
		数量显示.text = ""

func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()
