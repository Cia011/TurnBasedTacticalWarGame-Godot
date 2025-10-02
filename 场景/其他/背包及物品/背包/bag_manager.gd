extends Control
@onready var 鼠标槽: Node2D = $"0"
@export var 背包数组 : Array[基本背包ui]

func _ready() -> void:
	
	#此节点不算UI,仅仅算是一个容器,注册是为了快速寻找
	UiManager.register_ui(self)
	
	for 背包 in 背包数组:
		背包.mouse_0_change.connect(Callable(self,"mouse_0_change"))
func mouse_0_change(物品:BaseItem):
	鼠标槽.set_item(物品)
	for 背包 in 背包数组:
		背包.背包系统.items[0] = 物品

#先在槽位里判断鼠标输入事件,若没有拦截成功则把物品放回默认(索引0)背包
func _unhandled_input(event: InputEvent) -> void:
	if 鼠标槽.item == null:return
	if event is InputEventMouseButton and event.pressed:
		背包数组[0].背包系统.add_item(鼠标槽.item)
		
		for 背包 in 背包数组:
			背包.背包系统.items[0] = null
			鼠标槽.set_item(null)
