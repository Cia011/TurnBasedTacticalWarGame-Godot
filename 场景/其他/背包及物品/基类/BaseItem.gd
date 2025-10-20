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
func get_properties()->Dictionary:
	var properties:Dictionary ={
		"id":id,
		"item_name":item_name,
		# "texture":texture,
		"texture_path": texture.resource_path if texture else "",
		"max_stack":max_stack,
		"number":number,
		"description":description,
		"item_type":item_type
	}
	return properties

func has_property(property:String)->bool:
	if get_properties().has(property):
		return true
	return false


func restore_from_data(data: Dictionary)->bool:
	# 恢复基本属性
	#print("恢复基本属性"+str(data))
	id = data.get("id", id)
	item_name = data.get("item_name", item_name)
	max_stack = data.get("max_stack", max_stack)
	number = data.get("number", number)
	description = data.get("description", description)
	item_type = data.get("item_type", item_type)
	
	# 恢复纹理（从路径加载）
	var texture_path = data.get("texture_path", "")
	if texture_path and ResourceLoader.exists(texture_path):
		texture = load(texture_path)
	else:
		# 如果路径不存在，保持原有纹理或设为null
		texture = null
		if texture_path:
			push_warning("纹理路径不存在: " + texture_path)
	
	# 验证恢复是否成功（可选）
	if id == "" and data.has("id"):
		push_error("物品ID恢复失败")
		return false
	
	return true
#静态创建方法
static func create_from_data(data: Dictionary) -> BaseItem:
	var item = BaseItem.new()
	if item.restore_from_data(data):
		return item
	else:
		push_error("创建失败")
		return null
