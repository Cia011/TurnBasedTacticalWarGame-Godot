extends Node
signal show_unit_data(unit_data:UnitData)

var open_ui_nodes: Array[Control] = []
var ui_nodes:Array[Control] = []

#未实现
func is_mouse_over_on_UI()->bool:
	return false

func have_ui_opening()->bool:
	return not open_ui_nodes.is_empty()

func open_ui(ui_node: Control)->bool:
	if open_ui_nodes.has(ui_node):
		return false
	open_ui_nodes.append(ui_node)
	return true
func close_ui(ui_node: Control)->bool:
	if not open_ui_nodes.has(ui_node):
		return false
	open_ui_nodes.erase(ui_node)
	return true
#登记/注册 UI
func register_ui(ui_node: Control):
	if ui_nodes.has(ui_node):
		return
	ui_nodes.append(ui_node)
#注销 UI
func unregister_ui(ui_node: Control):
	if not ui_nodes.has(ui_node):
		return
	ui_nodes.erase(ui_node)
	
func get_ui(ui_name: String)->Control:
	for ui_node in ui_nodes:
		if ui_node.name == ui_name:
			return ui_node
	return null
	
	


#func open_bag():
	#var bag_manager = get_ui("BagManager")
	#bag_manager.visible = true
	#if not open_ui(bag_manager):
		#close_ui(bag_manager)
		#bag_manager.visible = false

#Topmenu里的按钮调用了这个函数
func change_bagmanager_state():
	var bag_manager = get_ui("BagManager")
	if bag_manager.visible == true:
		bag_manager.visible = false
		close_ui(bag_manager)
	else:
		bag_manager.visible = true
		open_ui(bag_manager)
