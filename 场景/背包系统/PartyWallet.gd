extends Node
## 队伍钱包（自动加载：PartyWallet）
## 管理队伍金币，供物品买卖逻辑调用。

signal money_changed(old_value: int, new_value: int)

var money: int = 500:
	set(value):
		var old := money
		money = max(0, value)
		if old != money:
			money_changed.emit(old, money)

func can_afford(amount: int) -> bool:
	return money >= amount

func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false
	money -= amount
	return true

func earn(amount: int) -> void:
	money += amount


func get_save_data() -> Dictionary:
	return {"money": money}


func apply_save_data(data: Dictionary) -> void:
	if data.has("money"):
		money = int(data["money"])
