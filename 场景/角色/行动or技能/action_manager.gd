extends Node
class_name ActionsManager

var actions:Array[BaseAction] = []

#在ready里自动注册行动
func _ready() -> void:
	#var moveaction = MoveAction.new()
	#moveaction.unit = $".."
	#add_child(moveaction)
	
	#自动将自身子节点注册到actions数组
	for action :BaseAction in get_children():
		register_action(action)

func get_action(action_id : String)->BaseAction:
	var results =  actions.filter(func(action:BaseAction):return action.action_id == action_id)
	if results and not results.is_empty():
		return results[0]
	return null

func register_action(action:BaseAction) -> void:
	actions.append(action)

func unregister_action(action:BaseAction) -> void:
	actions.erase(action)
