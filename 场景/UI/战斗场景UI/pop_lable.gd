extends Node2D
@onready var label: Label = $Label

func set_up(position:Vector2,text:String,color:Color = Color.WHITE):
	label.text = text
	label.label_settings = label.label_settings.duplicate()
	label.label_settings.font_color = color
	self.position = position
