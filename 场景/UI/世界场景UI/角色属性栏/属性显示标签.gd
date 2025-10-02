extends MarginContainer

@onready var value: Label = $HBoxContainer/MarginContainer2/value
@onready var key: Label = $HBoxContainer/MarginContainer/key

func set_up(key:String,value:String):
	name = key
	self.key.text = key+":"
	self.value.text = value
