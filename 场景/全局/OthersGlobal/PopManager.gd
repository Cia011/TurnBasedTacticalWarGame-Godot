extends Node
var special_effects_node : Node
const PopLable = preload("res://场景/UI/战斗场景UI/弹窗弹幕/pop_lable.tscn")
func pop_lable(position:Vector2,text:String,color:Color = Color.WHITE):
	var pop_label = PopLable.instantiate()
	special_effects_node.add_child(pop_label)
	pop_label.set_up(position,text,color)
	
