#此节点是技能卡片UI的管理器,工厂.负责生成卡片UI,对其进行初始化
#当BattleTurnManager选择新角色时,触发一系列动作


extends MarginContainer
@export var action_card_ui_scence : PackedScene
#@onready var action_container: HBoxContainer = $MarginContainer/ActionContainer
@onready var action_container: HBoxContainer = $MarginContainer2/MarginContainer/HBoxContainer2/HBoxContainer
@onready var 行动点label: Label = $MarginContainer2/MarginContainer/HBoxContainer2/HBoxContainer3/MarginContainer/行动点label
@onready var 结束回合按钮: Button = $MarginContainer2/MarginContainer/HBoxContainer2/HBoxContainer3/结束回合按钮

var unit:Unit
func _ready() -> void:
	BattleTurnManager.signal_change_unit.connect(on_change_unit)
	for card in action_container.get_children():
		card.signal_action_selected.connect(BattleActionManager.set_selected_action)
		
func updata_action_points_ui(new_value:int):
	行动点label.text = str(new_value) + "\n行动点"
#func on_change_unit(unit:Unit):
	#for card in action_container.get_children():
		#card.queue_free()
	#for action in unit.action_manager.actions:
		##生成技能卡片实例
		#var action_card_ui : ActionCardUI= action_card_ui_scence.instantiate()
		#action_card_ui.set_up(action)
		#action_container.add_child(action_card_ui)
		##当点击技能卡片时调用BattleActionManager的set_selected_action函数 更新其当前选择的action
		##BattleActionManager 主要负责触发 action 的执行
		##将卡片的点击信号连接至BattleActionManager
		#action_card_ui.signal_action_selected.connect(BattleActionManager.set_selected_action)
func on_change_unit(unit:Unit):
	if self.unit != null:
		self.unit.current_action_points_changed.disconnect(updata_action_points_ui)
	unit.current_action_points_changed.connect(updata_action_points_ui)
	updata_action_points_ui(unit.get_action_points())
	self.unit = unit
	var actions_card := action_container.get_children()
	var actions := unit.action_manager.actions
	for index in actions_card.size():
		var card = actions_card[index]
		if index < actions.size():
			var action:BaseAction = actions[index]
			card.set_up(action)
		else:
			card.set_up()
	结束回合按钮.set_up(unit)
	
