extends Node2D

# 信号，当火球到达目标时发出
signal arrived_at_target
const BANG = preload("res://场景/角色/行动or技能/效果/bang.tscn")
# 火球属性
var speed: float = 100
var start_position: Vector2
var target_position: Vector2
var progress: float = 0.0
var arc_height: float = 20 # 抛物线高度
func initialize(start_pos: Vector2, target_pos: Vector2):
	start_position = start_pos
	target_position = target_pos
	global_position = start_pos
	
	# 面向目标方向
	look_at(target_pos)

func _ready():
	# 播放火球动画
	#$AnimationPlayer.play("fireball_fly")
	pass

func _process(delta):
	# 移动火球
	progress += delta * speed / start_position.distance_to(target_position)
	#global_position = start_position.lerp(target_position, progress)
	global_position = calculate_parabolic_position(progress)
	# 更新火球旋转，使其跟随运动方向
	update_rotation()
	# 检查是否到达目标
	if progress >= 1.0:
		# 播放爆炸效果
		#$AnimationPlayer.play("fireball_explode")
		#await $AnimationPlayer.animation_finished
		
		# 发出到达信号
		var bang = BANG.instantiate()
		PopManager.special_effects_node.add_child(bang)
		bang.position = global_position
		arrived_at_target.emit()
# 计算抛物线位置
func calculate_parabolic_position(t: float) -> Vector2:
	# 线性插值计算基础位置
	var base_position = start_position.lerp(target_position, t)
	
	# 计算抛物线高度
	var height = arc_height * sin(t * PI)
	
	# 添加高度偏移
	return Vector2(base_position.x, base_position.y - height)
# 更新火球旋转，使其跟随运动方向
func update_rotation():
	if progress < 1.0:
		# 计算下一帧的位置
		var next_t = min(progress + 0.01, 1.0)
		var next_pos = calculate_parabolic_position(next_t)
		
		# 计算方向向量
		var direction = next_pos - global_position
		
		# 设置旋转角度
		if direction.length() > 0:
			rotation = direction.angle()
