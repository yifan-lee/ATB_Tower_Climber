extends Node2D


const BloodshotEye = preload("res://entities/enemy/bloodshot_eye.gd") # 预加载敌人脚本
var bloodshot_eye_instance: CharacterBody2D

func _ready():
	var floor_bg = ColorRect.new()
	# 动态调用地图区域宽高
	floor_bg.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.EXPLORE_AREA_HEIGHT)
	floor_bg.color = Color(0.8, 0.9, 0.8)
	add_child(floor_bg)
	
	_create_boundaries()
	_load_enemies()

func _create_boundaries():
	var wall_thickness = GameConfig.WALL_THICKNESS
	var width = GameConfig.SCREEN_WIDTH
	var height = GameConfig.EXPLORE_AREA_HEIGHT
	var wall_color = Color(0.3, 0.3, 0.4)
	
	# 上边界 (中心点 X: 宽度一半, Y: 墙厚一半)
	_add_wall(Vector2(width / 2.0, wall_thickness / 2.0), Vector2(width, wall_thickness), wall_color)
	
	# 下边界 (中心点 X: 宽度一半, Y: 高度 - 墙厚一半)
	_add_wall(Vector2(width / 2.0, height - wall_thickness / 2.0), Vector2(width, wall_thickness), wall_color)
	
	# 左边界 (中心点 X: 墙厚一半, Y: 高度一半)
	_add_wall(Vector2(wall_thickness / 2.0, height / 2.0), Vector2(wall_thickness, height), wall_color)
	
	# 右边界 (中心点 X: 宽度 - 墙厚一半, Y: 高度一半)
	_add_wall(Vector2(width - wall_thickness / 2.0, height / 2.0), Vector2(wall_thickness, height), wall_color)

func _add_wall(pos: Vector2, size: Vector2, color: Color):
	var static_body = StaticBody2D.new()
	static_body.position = pos
	
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = size
	collision_shape.shape = rect_shape
	static_body.add_child(collision_shape)
	
	var visual = ColorRect.new()
	visual.size = size
	visual.color = color
	visual.position = - size / 2.0
	static_body.add_child(visual)
	
	add_child(static_body)

func _load_enemies():
	bloodshot_eye_instance = BloodshotEye.new()
	bloodshot_eye_instance.position = Vector2(
		GameConfig.WALL_THICKNESS + GameConfig.GRID_SIZE * (GameConfig.GRID_COLUMNS + 1.0) / 2.0 - GameConfig.GRID_SIZE / 2.0,
		GameConfig.GRID_SIZE / 2.0
	)
	add_child(bloodshot_eye_instance)
