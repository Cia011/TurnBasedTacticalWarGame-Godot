extends Node
@onready var PopLable:PackedScene = preload("res://场景/UI/战斗场景UI/pop_lable.tscn")
var special_effects_node : Node

func pop_lable(position:Vector2,text:String,color:Color = Color.WHITE):
	var pop_label = PopLable.instantiate()
	special_effects_node.add_child(pop_label)
	pop_label.set_up(position,text,color)
	
