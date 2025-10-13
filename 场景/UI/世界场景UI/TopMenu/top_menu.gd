extends MarginContainer


func _on_设置按钮_pressed() -> void:
	pass # Replace with function body.


func _on_帮助按钮_pressed() -> void:
	pass # Replace with function body.


func _on_菜单按钮_pressed() -> void:
	pass # Replace with function body.


func _on_背包按钮_pressed() -> void:
	UiManager.open_team_backpack()

# 在主菜单脚本中添加存档按钮功能
func _on_存档按钮_pressed() -> void:
	# 检查是否可以在当前场景存档
	if WorldSaveManager.can_save_in_current_scene():
		# 显示存档界面
		var save_ui = preload("res://场景/UI/世界场景UI/存档界面/WorldSaveLoadUI.tscn").instantiate()
		UiManager.get_ui("UI").add_child(save_ui)
		save_ui.show_ui()
