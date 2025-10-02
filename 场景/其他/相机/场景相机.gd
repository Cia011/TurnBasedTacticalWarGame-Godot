extends Camera2D
# 拖拽相关变量
var is_dragging: bool = false
var drag_start_position: Vector2
var camera_start_position: Vector2

# 缩放相关变量
var zoom_speed: float = 0.1
var min_zoom: float = 1
var max_zoom: float = 5
func _ready() -> void:
	#position
	pass


func _input(event):
	handle_dragging(event)
	handle_zooming(event)

func handle_dragging(event: InputEvent):
	# 鼠标中键按下开始拖拽
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				# 开始拖拽
				is_dragging = true
				drag_start_position = event.position
				camera_start_position = position
			else:
				# 结束拖拽
				is_dragging = false
	
	# 鼠标移动时拖拽相机
	elif event is InputEventMouseMotion:
		if is_dragging:
			var drag_offset = (drag_start_position - event.position) / zoom
			position = camera_start_position + drag_offset

func handle_zooming(event: InputEvent):
	if event is InputEventMouseButton:
		# 滚轮缩放
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_speed, get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_speed, get_global_mouse_position())

func zoom_camera(zoom_delta: float, zoom_center: Vector2):
	var old_zoom : Vector2= zoom
	var new_zoom : Vector2= old_zoom * (1.0 + zoom_delta)
	
	# 限制缩放范围
	new_zoom = clamp(new_zoom, Vector2(min_zoom,min_zoom),Vector2(max_zoom,max_zoom))
	
	if new_zoom != old_zoom:
		# 应用新缩放
		zoom = new_zoom
