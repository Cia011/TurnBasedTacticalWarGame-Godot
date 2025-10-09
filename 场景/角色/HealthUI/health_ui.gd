extends Node2D
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func _ready() -> void:
	pass
	
func set_up(max_health,current_health,is_teammate = true):
	progress_bar.max_value = max_health
	progress_bar.value=current_health
	label.text = str(current_health)
	if is_teammate == false:
		label.label_settings = label.label_settings.duplicate()
		label.label_settings.font_color = Color.RED
		var fill_style = progress_bar.get_theme_stylebox("fill").duplicate() # 获取填充条样式
		if fill_style is StyleBoxFlat: # 确保是 StyleBoxFlat 类型
			fill_style.bg_color = Color.RED # 将填充背景色改为红色
		progress_bar.add_theme_stylebox_override("fill", fill_style)
func update(new_health):
	if progress_bar.value == new_health:
		return
	progress_bar.value = max(new_health,0)
	label.text = str(new_health)
