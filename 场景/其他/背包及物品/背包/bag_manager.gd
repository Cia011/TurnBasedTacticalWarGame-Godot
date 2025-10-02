extends Control
@onready var 鼠标槽: Node2D = $"0"
@onready var 背包容器节点: HBoxContainer = $HBoxContainer

func _ready() -> void:
	
	#此节点不算UI,仅仅算是一个容器,注册是为了快速寻找
	UiManager.register_ui(self)
	GameState.signal_mouse_slot_change.connect(mouse_0_change)

#更新鼠标上的物品
func mouse_0_change(物品:BaseItem):
	鼠标槽.set_item(物品)

#先在槽位里判断鼠标输入事件,若没有拦截成功则把物品放回默认(索引0)背包
func _unhandled_input(event: InputEvent) -> void:
	if 鼠标槽.item == null:return
	if event is InputEventMouseButton and event.pressed:
		GameState.all_backpacks[0].add_item(GameState.get_mouse_slot_item())
		GameState.set_mouse_slot_item(null)
