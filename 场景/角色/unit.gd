extends Node2D
class_name Unit


@onready var action_manager: ActionsManager = $ActionsManager
@onready var health_ui: Node = $HealthUI

var data_manager: DataManager
var buff_manager: BuffManager

var is_teammate : bool = true
var pre_health:int
var current_action_points:int
var AI : BaseAI
signal unit_die(unit:Unit)
signal current_action_points_changed(new_value:int)

var grid_position :Vector2i:
	get:return BattleGridManager.get_grid_position(global_position)
	#set(value): grid_position = value
	
var unit_data:UnitData
#从data_manager中获取属性
#单独写一个函数是为了方便使用 即 委托方法
func get_stat(stat_name:String):
	return unit_data.get_final_stat(stat_name)
func get_action_points()->int:
	return current_action_points
func set_action_points(num:int):
	current_action_points = num
	current_action_points_changed.emit(num)
	
func start_turn():
	current_action_points = unit_data.get_final_stat("action_points")
	if is_teammate == false:
		start_enemy_turn()
	
func start_enemy_turn():
	await AI.take_turn()
	#await AI.turn_completed
#再ready前执行
func set_up(unit_data:UnitData,grid_position:Vector2i):
	self.unit_data = unit_data
	name = self.unit_data.character_name
	set_grid_position(grid_position)
	
	data_manager = unit_data.data_manager
	buff_manager = unit_data.buff_manager
	data_manager.unit_data_change.connect(unit_data_change)

func _ready() -> void:
	#角色创建时在BattleUnitManager内注册
	BattleUnitManager.register_unit(self)
	
	pre_health = get_stat("current_health")
	
	#角色创建时设置HealthUI#初始化
	#health_ui.set_up(unit_data.max_health,unit_data.current_health)
	health_ui.set_up(get_stat("max_health"),get_stat("current_health"),is_teammate)
	
	if is_teammate == false:
		
		AI = AggressiveEnemyAI.new(self)
		add_child(AI)
	

#由角色生成器来控制生成角色的位置,目前角色生成器为战斗场景根节点
func set_grid_position(grid_position:Vector2i)->void:
	#设置位置
	position = BattleGridManager.get_world_position(grid_position)
	#在相应位置网格注册自身
	BattleGridManager.set_grid_occupied(grid_position,self)
#当属性管理器发生改变时自动执行(因为连接了信号)
func unit_data_change(new_stats:Dictionary):
	if new_stats.has("current_health"):
		#受伤弹幕
		var change_health:int = new_stats["current_health"]-pre_health
		if(change_health<=0):
			PopManager.pop_lable(self.position,str(new_stats["current_health"]-pre_health),Color.RED)
		elif(change_health>0):
			PopManager.pop_lable(self.position,"+"+str(new_stats["current_health"]-pre_health),Color.GREEN)
		
		health_ui.set_up(get_stat("max_health"),get_stat("current_health"))
		
		#死亡逻辑
		if get_stat("current_health")<=0:
			unit_die.emit(self)
		pre_health = new_stats["current_health"]
