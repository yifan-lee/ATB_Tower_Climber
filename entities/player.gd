# res://entities/player.gd
extends CharacterBody2D

# 记录当前面朝的方向，默认向下
# var facing_direction = "down"
var anim_sprite: AnimatedSprite2D

func _ready():
	add_to_group("player")
	z_index = 10 # 强制让玩家渲染在最上层，避免被新加载的地图背景遮挡
	_setup_sprite()
	_setup_collision()

func _setup_sprite():
	anim_sprite = GameConfig.create_scaled_anim_sprite("res://assets/sprites/player/blonde_man_animations.tres", GameConfig.GRID_SIZE)
	add_child(anim_sprite)

func _setup_collision():
	var collision = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	# 碰撞体设置为 60x60（或者稍微小于 64 的尺寸），留出容错空间防止卡墙
	rect.size = Vector2(60, 60)
	collision.shape = rect
	add_child(collision)

func _unhandled_input(event):
	var direction = Vector2.ZERO
	
	if event.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT
	elif event.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
	elif event.is_action_pressed("ui_down"):
		direction = Vector2.DOWN
	elif event.is_action_pressed("ui_up"):
		direction = Vector2.UP
		
	if direction != Vector2.ZERO:
		_try_move(direction)

func _try_move(direction: Vector2):
	var current_transform = Transform2D(0, position)
	
	# 直接调用全局配置中的网格大小计算真实位移距离 [cite: 12]
	var motion = direction * GameConfig.GRID_SIZE

	# 实例化一个碰撞数据收集器
	var collision = KinematicCollision2D.new()
	
	# 探测前方是否撞墙，将 collision 传给引擎以获取碰撞信息
	if not test_move(current_transform, motion, collision):
		# 没有撞墙，执行瞬间移动
		position += motion
		anim_sprite.play("walk")
		var grid_pos = GameConfig.get_grid_position(position)
		EventBus.player_stepped.emit(grid_pos)
	else:
		# 撞墙了，播放待机动画
		anim_sprite.play("idle")
		var collider = collision.get_collider()
		_handle_interaction(collider)

func _handle_interaction(collider: Object):
	# 1. 判断是否撞到了瓦片地图 (当前我们给外围墙壁加了 StaticBody2D，内部墙壁是 TileMap)
	if collider is TileMap or collider is StaticBody2D:
		# 触发撞墙的文本提示
		EventBus.show_system_message.emit("MSG_HIT_WALL")
		return
	elif collider.is_in_group("enemy"):
		EventBus.show_system_message.emit("MSG_HIT_ENEMY")
		EventBus.encounter_monster.emit(collider.monster_id, collider)
