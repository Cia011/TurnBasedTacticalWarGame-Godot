extends Control
var popup_menu : PopupMenu
#id->Resource
var data_dictionaries:Dictionary[int,Object]
var mouse_grid_position:Vector2i
func _ready():
	# 创建弹出菜单
	popup_menu = PopupMenu.new()
	add_child(popup_menu)
	
	
	
	# 连接信号
	popup_menu.id_pressed.connect(_on_menu_item_selected)
	popup_menu.popup_hide.connect(_on_popup_hide)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# 确保点击在地块上
			mouse_grid_position = WorldGridManager.get_mouse_grid_position()
			if WorldGridManager.is_valid_grid(mouse_grid_position):
				var grid_data : WorldGrid = WorldGridManager.get_grid_data(mouse_grid_position)
				
				popup_menu.position = get_global_mouse_position()
				creat_items(mouse_grid_position)
				
				popup_menu.popup()
				UiManager.open_ui(self)
				#get_viewport().set_input_as_handled()
				accept_event()
func creat_items(mouse_grid_position:Vector2i):
	popup_menu.clear()
	data_dictionaries.clear()
	var id:int = 0
	
	var event:BaseEvent = WorldEventManager.get_grid_event(mouse_grid_position)
	
	if mouse_grid_position == GameState.baseteam_node.grid_position:
		if event:
			var item:String = event.name
			popup_menu.add_item(item,id)
			data_dictionaries[id] = event
			id+=1;
	
	#
	popup_menu.add_item("移动",100)
	
	
	popup_menu.add_separator()
	popup_menu.add_item("取消",999)


func _on_menu_item_selected(id):
	if id == 999:
		return
	elif  id == 100:
		GameState.baseteam_node.get_path_and_try_move(mouse_grid_position)
	elif data_dictionaries[id] is BaseEvent:
		data_dictionaries[id].apply_effect()
func _on_popup_hide():
	UiManager.close_ui(self)
