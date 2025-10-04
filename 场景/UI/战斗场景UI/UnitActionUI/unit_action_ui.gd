#此节点是技能卡片UI的管理器,工厂.负责生成卡片UI,对其进行初始化
#当BattleTurnManager选择新角色时,触发一系列动作


extends MarginContainer
@export var action_card_ui_scence : PackedScene
@onready var action_container: HBoxContainer = $MarginContainer/ActionContainer

func _ready() -> void:
	BattleTurnManager.signal_change_unit.connect(on_change_unit)
	

func on_change_unit(unit:Unit):
	for card in action_container.get_children():
		card.queue_free()
	
	
	for action in unit.action_manager.actions:
		#生成技能卡片实例
		var action_card_ui : ActionCardUI= action_card_ui_scence.instantiate()
		action_card_ui.set_up(action)
		action_container.add_child(action_card_ui)
		#当点击技能卡片时调用BattleActionManager的set_selected_action函数 更新其当前选择的action
		#BattleActionManager 主要负责触发 action 的执行
		#将卡片的点击信号连接至BattleActionManager
		action_card_ui.signal_action_selected.connect(BattleActionManager.set_selected_action)
