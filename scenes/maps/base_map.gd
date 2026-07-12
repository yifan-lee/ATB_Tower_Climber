# res://scenes/maps/base_map.gd
extends Node2D

var tile_map: TileMap

# 基类预留一个空的 map_data，等待子类去覆盖它
var map_data = []

# 楼梯配置字典。由各个具体楼层在_init()中自定义填充
var stairs_config = {}

# 预加载你需要用到的敌人脚本
const BloodshotEye = preload("res://entities/enemy/bloodshot_eye.gd")

func _ready():
	# 只要子类一运行，就会自动执行这些通用代码
	var floor_bg = ColorRect.new()
	# 动态调用地图区域宽高
	floor_bg.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.EXPLORE_AREA_HEIGHT)
	floor_bg.color = Color(0.8, 0.9, 0.8)
	add_child(floor_bg)
	_create_boundaries()

	_setup_tilemap()
	_build_map_from_data()

	# 监听玩家的移动踩踏事件
	EventBus.player_stepped.connect(_on_player_stepped)

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
	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
			var cell_value = map_data[y][x]
			
			if cell_value == 1:
				# 绘制墙壁 [cite: 45]
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(16, 6))
			elif cell_value == 2:
				# 绘制楼梯 [cite: 45]
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(16, 3))
			elif cell_value == 11:
				# 遇到 11，生成大眼球怪物
				_spawn_enemy(BloodshotEye, x, y)


func _spawn_enemy(enemy_class, grid_x: int, grid_y: int):
	var enemy_instance = enemy_class.new()
	
	# 坐标转换：将网格坐标(如 x:2, y:2) 转换为真实的像素坐标。
	# 正确的逻辑应该是加上半个格子的大小 (+32)，而不是减去 (-32)
	var pixel_x = grid_x * GameConfig.GRID_SIZE + (GameConfig.GRID_SIZE / 2.0) + GameConfig.WALL_THICKNESS
	var pixel_y = grid_y * GameConfig.GRID_SIZE + (GameConfig.GRID_SIZE / 2.0) + GameConfig.WALL_THICKNESS
	
	# 因为我们用了 TileMap，外圈的墙也是画在网格里的，
	# 所以直接按照网格算出来的 pixel_x 和 pixel_y 已经是绝对准确的，
	# 不需要再像以前那样加上复杂的 WALL_THICKNESS 偏移计算了！
	enemy_instance.position = Vector2(pixel_x, pixel_y)
	
	add_child(enemy_instance)


func _on_player_stepped(grid_pos: Vector2i):
	# 查字典：玩家当前踩的格子，是不是配置好的楼梯入口？
	if stairs_config.has(grid_pos):
		var config = stairs_config[grid_pos]
		# 发送切换地图请求
		EventBus.request_map_change.emit(config["target_scene"], config["spawn_grid"])