extends Node
#此全局变量用来执行角色的行动
var is_performing_action : bool = false
var selected_action : BaseAction


func _unhandled_input(event: InputEvent) -> void:
	if is_performing_action:
		return
	
	if event.is_action_pressed("left_mouse_clik"):
		try_perform_selected_action()

#当技能卡片被点击时触发此函数
func set_selected_action(action:BaseAction)->void:
	if is_performing_action:
		return
	if selected_action == action:
		return
	
	print("Select" + action.action_name)
	selected_action = action
	
	#若行动是瞬发,例如跳过回合 则直接触发
	if selected_action.is_instant:
		#print("尝试执行瞬发")
		selected_action.start_action(Vector2i(0,0),on_action_finished)
	else:
		#显示行动范围
		BattleGridManager.visulize_grids(selected_action.get_action_grids() ,selected_action.grid_color)
	
	
func try_perform_selected_action():
	if is_performing_action:
		return
	if selected_action == null:
		return
	#若行动是瞬发,则不会因为鼠标的输入尝试执行,因为在选中该技能时已经执行
	if selected_action.is_instant:
		return
	
	var target_grid_position = BattleGridManager.get_mouse_grid_position()
	
	#若target_grid_position不在行动范围,则返回
	if not selected_action.get_action_grids().has(target_grid_position):
		return
	
	is_performing_action = true
	selected_action.start_action(target_grid_position,on_action_finished)

func on_action_finished():
	is_performing_action = false

#设置默认行动,致力于在角色切换时自动选择move行动
func set_default_action():
	on_action_finished()
	var current_unit = BattleTurnManager.current_unit

	var default_action = current_unit.action_manager.get_action("MoveAction")

	

	
	#我不明白为何会如此
	await get_tree().create_timer(0.1).timeout
	#call_deferred("set_selected_action",default_action)
	set_selected_action(default_action)
