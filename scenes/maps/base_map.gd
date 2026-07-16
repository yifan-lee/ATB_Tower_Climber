# res://scenes/maps/base_map.gd
extends Node2D

var tile_map: TileMap

# 基类预留一个空的 map_data，等待子类去覆盖它
var map_data = []

# 楼梯配置字典。由各个具体楼层在_init()中自定义填充
var stairs_config = {}


func _ready():
	# 只要子类一运行，就会自动执行这些通用代码
	var floor_bg = ColorRect.new()
	# 动态调用地图区域宽高
	floor_bg.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	floor_bg.color = Color(0.8, 0.9, 0.8)
	add_child(floor_bg)

	_create_boundaries()
	_setup_tilemap()
	_build_map_from_data()


func _create_boundaries():
	var wall_thickness = GameConfig.WALL_THICKNESS
	var width = GameConfig.SCREEN_WIDTH
	var height = GameConfig.GAME_AREA_HEIGHT
	var wall_color = Color(0.3, 0.3, 0.4)
	
	_add_wall(Vector2(width / 2.0, wall_thickness / 2.0), Vector2(width, wall_thickness), wall_color)
	_add_wall(Vector2(width / 2.0, height - wall_thickness / 2.0), Vector2(width, wall_thickness), wall_color)
	_add_wall(Vector2(wall_thickness / 2.0, height / 2.0), Vector2(wall_thickness, height), wall_color)
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
	
	# 3. 偏移使得 TileMap 从墙壁内部起始
	tile_map.position = Vector2(GameConfig.WALL_THICKNESS, GameConfig.WALL_THICKNESS)
	
	add_child(tile_map)


var map_items = {} # 存储当前地图上的物品信息，格式为 { Vector2i(x,y): {"id": item_id, "node": sprite} }

# 新的泛用敌人预加载
const BaseEnemy = preload("res://entities/enemy/base_enemy.gd")

func _build_map_from_data():
	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
			var cell_value = str(map_data[y][x])
			var grid_pos = Vector2i(x, y)
			var pixel_position: Vector2 = GameConfig.get_game_area_pixel_position(x, y)
			
			if cell_value == "wall":
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(16, 6))
			elif cell_value == "stairs":
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(16, 3))
			elif cell_value == "" or cell_value == "0":
				pass
			else:
				# 动态判断：如果在实体数据库中，那就是怪
				if EntityDB.db.has(cell_value):
					_spawn_enemy(cell_value, pixel_position)
				# 动态判断：如果在物品数据库中，那就是道具
				elif ItemDB.db.has(cell_value):
					_spawn_item(cell_value, grid_pos, pixel_position)


func _spawn_item(item_id: String, grid_pos: Vector2i, pixel_position: Vector2):
	var item_data = ItemDB.get_item(item_id)
	if not item_data: return
	
	# 纯视觉表现，不再需要任何物理节点！
	var sprite = Sprite2D.new()
	if item_data.icon:
		sprite.texture = item_data.icon
		var orig_size = sprite.texture.get_size()
		var target_size = GameConfig.GRID_SIZE
		sprite.scale = Vector2(target_size / orig_size.x, target_size / orig_size.y)
	sprite.position = pixel_position
	add_child(sprite)
	
	# 将物品信息注册到地图字典中
	map_items[grid_pos] = {
		"id": item_id,
		"node": sprite
	}


func _spawn_enemy(monster_id: String, pixel_position: Vector2):
	var enemy_instance = BaseEnemy.new()
	# 赋予基类灵魂！
	enemy_instance.setup(monster_id)
	enemy_instance.position = pixel_position
	add_child(enemy_instance)

# 只有当旧地图挂载到场景树上时，才监听玩家脚步声；
# 当它被 remove_child 扔到缓存里时，立刻断开监听！
# 这从根本上杜绝了隐形地图抢听信号、或者在同一帧内连续互相传送的终极 Bug。
func _enter_tree():
	if not EventBus.player_stepped.is_connected(_on_player_stepped):
		EventBus.player_stepped.connect(_on_player_stepped)

func _exit_tree():
	if EventBus.player_stepped.is_connected(_on_player_stepped):
		EventBus.player_stepped.disconnect(_on_player_stepped)
		
func _on_player_stepped(grid_pos: Vector2i):
	# 查字典：玩家当前踩的格子，是不是配置好的楼梯入口？
	if stairs_config.has(grid_pos):
		var config = stairs_config[grid_pos]
		# 发送切换地图请求
		EventBus.request_map_change.emit(config["target_scene"], config["spawn_grid"])
		
	# 查字典：玩家当前踩的格子，有没有物品？
	if map_items.has(grid_pos):
		var item_info = map_items[grid_pos]
		var item_id = item_info["id"]
		var item_data = ItemDB.get_item(item_id)
		
		# 添加到背包
		var stats = EntityDB.get_stats("player")
		if stats.inventory.has(item_id):
			stats.inventory[item_id] += 1
		else:
			stats.inventory[item_id] = 1
			
		EventBus.show_system_message.emit(["MSG_GOT_ITEM", item_data.item_name])
		
		# 销毁节点并从字典中移除
		item_info["node"].queue_free()
		map_items.erase(grid_pos)
