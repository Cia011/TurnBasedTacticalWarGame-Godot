extends Node
#连接致AttributePanel节点,更新属性UI
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
func get_opening_ui(ui_name: String)->Control:
	for ui_node in open_ui_nodes:
		if ui_node.name == ui_name:
			return ui_node
	return null
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
	
	


#-----------------背包部分-------------------------
#队伍背包场景
const BAG_UI_SCENE = preload("res://场景/其他/背包及物品/实现/bag_ui.tscn")

func open_team_backpack():
	if get_opening_ui("BagUI"):
		return
	
	var bag_ui = BAG_UI_SCENE.instantiate()
	
	var bag_manager = get_ui("BagManager")
	var 背包容器节点 = bag_manager.背包容器节点 as Control
	背包容器节点.add_child(bag_ui)
	#bag_ui的set_up在自身ready里调用了,先不实现
