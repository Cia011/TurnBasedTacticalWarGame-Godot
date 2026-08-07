extends BaseContainerService
class_name ShopService

## 加载货物
func load_goods(shop_name: String, goods: Array[ItemData]) -> void:
	for good in goods:
		_container_repository.get_container(shop_name).add_item(good.duplicate())

## 购买物品
func buy(shop_name: String, item: ItemData) -> bool:
	if ShopManager.has_method("try_buy"):
		return ShopManager.try_buy(shop_name, item)
	return item.buy()

## 出售物品
func sell(item: ItemData) -> bool:
	if ShopManager.has_method("try_sell"):
		return ShopManager.try_sell(item)
	if item.can_sell():
		item.sold()
		GBIS.moving_item_service.clear_moving_item()
		return true
	return false

## 只返回商店
func get_container(container_name: String) -> ContainerData:
	if GBIS.shop_names.has(container_name):
		return _container_repository.get_container(container_name)
	return null
