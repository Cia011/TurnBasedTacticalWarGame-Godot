class_name TownEvent extends BaseEvent
## 城镇/商人事件：永久存在，触发后打开对应商店。

@export var shop_name: String = "杂货铺"

func _init() -> void:
	type = "town"
	duration = -1
	name = "城镇"
	description = "进入城镇，可以和商人交易。"

func apply_effect() -> void:
	ShopManager.open_shop(shop_name)

func serialize() -> Dictionary:
	var data := super.serialize()
	data["shop_name"] = shop_name
	return data

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	shop_name = data.get("shop_name", shop_name)
