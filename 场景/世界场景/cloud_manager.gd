extends CanvasLayer

# 云彩Shader参数
@onready var cloud_shader_material: ShaderMaterial
@export var cloud_speed: float = 0.5
@export var cloud_density: float = 0.3
@export var darkness_intensity: float = 0.4
@export var cloud_color: Color = Color(0.8, 0.8, 0.9, 1.0)

func _ready():
	# 创建Shader材质
	cloud_shader_material = ShaderMaterial.new()
	cloud_shader_material.shader = preload("res://shaders/cloud_shader.gdshader")
	
	# 设置初始参数
	update_shader_parameters()
	
	# 添加到场景
	var cloud_sprite = Sprite2D.new()
	cloud_sprite.texture = create_cloud_texture()
	cloud_sprite.material = cloud_shader_material
	cloud_sprite.position = get_viewport().get_visible_rect().size / 2
	cloud_sprite.scale = Vector2(2, 2)  # 放大以覆盖整个屏幕
	add_child(cloud_sprite)
	
	print("[CloudManager] 云彩效果已初始化")

func _process(delta):
	# 更新时间参数
	if cloud_shader_material:
		cloud_shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

# 创建云彩纹理（透明纹理，用于Shader处理）
func create_cloud_texture() -> Texture2D:
	var image = Image.create(1080, 1080, false, Image.FORMAT_RGBA8)
	#var image = Image.create(1080, 1080, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	#image.fill(Color(Color.ALICE_BLUE,0.2))
	var texture = ImageTexture.create_from_image(image)
	return texture

# 更新Shader参数
func update_shader_parameters():
	if cloud_shader_material:
		cloud_shader_material.set_shader_parameter("cloud_speed", cloud_speed)
		cloud_shader_material.set_shader_parameter("cloud_density", cloud_density)
		cloud_shader_material.set_shader_parameter("darkness_intensity", darkness_intensity)
		cloud_shader_material.set_shader_parameter("cloud_color", cloud_color)

# 公共方法：调整云彩效果
func set_cloud_speed(speed: float):
	cloud_speed = speed
	update_shader_parameters()

func set_cloud_density(density: float):
	cloud_density = density
	update_shader_parameters()

func set_darkness_intensity(intensity: float):
	darkness_intensity = intensity
	update_shader_parameters()

# 随机改变云彩效果（模拟天气变化）
func randomize_clouds():
	cloud_speed = randf_range(0.2, 1.0)
	cloud_density = randf_range(0.1, 0.6)
	darkness_intensity = randf_range(0.2, 0.6)
	update_shader_parameters()
	print("[CloudManager] 云彩效果已随机化")

# 获取当前云彩状态
func get_cloud_status() -> Dictionary:
	return {
		"speed": cloud_speed,
		"density": cloud_density,
		"darkness": darkness_intensity
	}
