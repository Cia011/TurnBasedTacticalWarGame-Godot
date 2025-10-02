extends Node
class_name BaseAction

@export var action_id : String
@export var action_name : String
@export var grid_color : Color = Color.WHITE

var unit:Unit
var is_actioning : bool = false
var on_action_finished : Callable


var is_need_target : bool = true
var is_instant : bool = false

func _ready() -> void:
	unit = owner

#Callable回调函数,在其他脚本中传入,action执行结束自动触发 Callable函数
func start_action(target_grid_position : Vector2i,on_action_finished: Callable)->void:
	is_actioning = true
	self.on_action_finished = on_action_finished
func finish_action()->void:
	is_actioning = false
	on_action_finished.call()

#显示范围
func get_action_grids(unit_grid:Vector2i = unit.grid_position)->Array[Vector2i]:
	return []
