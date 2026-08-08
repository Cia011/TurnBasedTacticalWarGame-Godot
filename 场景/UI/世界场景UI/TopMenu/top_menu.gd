extends MarginContainer


func _on_背包按钮_pressed() -> void:
	var bag_ui = UiManager.get_ui("TeamInventoryUI")
	if bag_ui and bag_ui.has_method("toggle"):
		bag_ui.toggle()


func _on_商店按钮_pressed() -> void:
	ShopManager.open_shop("杂货铺")


func _on_设置按钮_pressed() -> void:
	pass # Replace with function body.


func _on_帮助按钮_pressed() -> void:
	pass # Replace with function body.


func _on_菜单按钮_pressed() -> void:
	pass # Replace with function body.


func _on_存档按钮_pressed() -> void:
	var save_ui = UiManager.get_ui("SaveUI")
	if save_ui and save_ui.has_method("open_save"):
		save_ui.open_save()


func _on_读档按钮_pressed() -> void:
	var save_ui = UiManager.get_ui("SaveUI")
	if save_ui and save_ui.has_method("open_load"):
		save_ui.open_load()
