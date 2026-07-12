extends Node2D


const BloodshotEye = preload("res://entities/enemy/bloodshot_eye.gd") # 预加载敌人脚本
var bloodshot_eye_instance: CharacterBody2D

var tile_map: TileMap
var map_data = [
	[2, 0, 1, 0, 2],
	[0, 0, 1, 0, 0],
	[0, 1, 1, 1, 0],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 1, 1]
]

# 1 is wall; 2 is ladder

func _ready():
	var floor_bg = ColorRect.new()
	# 动态调用地图区域宽高
	floor_bg.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.EXPLORE_AREA_HEIGHT)
	floor_bg.color = Color(0.8, 0.9, 0.8)
	add_child(floor_bg)
	
	_create_boundaries()
	_setup_tilemap()
	_build_map_from_data()
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


func _setup_tilemap():
	tile_map = TileMap.new()

	# 1. 纯代码加载我们在编辑器做好的图集资源
	tile_map.tile_set = load("res://assets/tilesets/wall.tres")
	
	# 2. 放大 4 倍，使得 16x16 的素材刚好填满 64x64 的逻辑格子
	tile_map.scale = Vector2(4, 4)
	
	add_child(tile_map)


func _build_map_from_data():
	# 遍历我们的二维数组
	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
			# 如果数组里写的是 1，我们就放置一块墙壁
			if map_data[y][x] == 1:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(16, 6))
			elif map_data[y][x] == 2:
			    tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(16, 3))


func _load_enemies():
	bloodshot_eye_instance = BloodshotEye.new()
	bloodshot_eye_instance.position = Vector2(
		GameConfig.WALL_THICKNESS + GameConfig.GRID_SIZE * (GameConfig.GRID_COLUMNS + 1.0) / 2.0 - GameConfig.GRID_SIZE / 2.0,
		GameConfig.GRID_SIZE / 2.0
	)
	add_child(bloodshot_eye_instance)
