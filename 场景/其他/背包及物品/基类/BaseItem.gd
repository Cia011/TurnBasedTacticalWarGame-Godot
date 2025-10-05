extends Resource
class_name BaseItem
@export_category("物品信息")
@export var id: String = ""  # 物品唯一ID
@export var item_name: String = ""  # 物品名称
@export var texture: Texture2D  # 物品图标
@export var max_stack: int = 1  # 最大堆叠数量
@export var number : int = 1 #当前堆叠数量
@export var description: String = ""  # 物品描述
@export var item_type: String = "任意"
