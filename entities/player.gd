# res://entities/player.gd
extends CharacterBody2D

# 记录当前面朝的方向，默认向下
# var facing_direction = "down"
var anim_sprite: AnimatedSprite2D

func _ready():
	add_to_group("player")
	z_index = 10 # 强制让玩家渲染在最上层，避免被新加载的地图背景遮挡
	_setup_sprite()

func _setup_sprite():
	var stats = EntityDB.get_stats("player")
	anim_sprite = GameConfig.create_scaled_anim_sprite(stats.anim_path, GameConfig.GRID_SIZE)
	add_child(anim_sprite)

var move_cooldown: float = 0.0
const MOVE_DELAY: float = 0.15 # 0.15秒移动一格

func _process(delta: float):
	if move_cooldown > 0:
		move_cooldown -= delta
		return
		
	var direction = Vector2.ZERO
	
	# 使用 GameConfig 里的抽象方法检测按键状态
	if GameConfig.is_pressing_up():
		direction = Vector2.UP
	elif GameConfig.is_pressing_down():
		direction = Vector2.DOWN
	elif GameConfig.is_pressing_left():
		direction = Vector2.LEFT
	elif GameConfig.is_pressing_right():
		direction = Vector2.RIGHT
			
	if direction != Vector2.ZERO:
		_try_move(direction)
		move_cooldown = MOVE_DELAY

func _try_move(direction: Vector2):
	var target_pixel_pos = position + direction * GameConfig.GRID_SIZE
	var target_grid_pos = GameConfig.get_grid_position(target_pixel_pos)
	
	var main = get_parent().get_parent()
	if not main or not main.get("current_map"):
		return
		
	var map_node = main.current_map
	
	if not map_node.is_passable(target_grid_pos):
		anim_sprite.play("idle")
		EventBus.show_system_message.emit("MSG_HIT_WALL")
		return
		
	var entity = map_node.get_entity_at(target_grid_pos)
	if not entity.is_empty() and entity.get("is_enemy", false):
		anim_sprite.play("idle")
		EventBus.show_system_message.emit("MSG_HIT_ENEMY")
		EventBus.encounter_monster.emit(entity["id"], entity["node"])
		return

	# 在真正执行移动前，检查自定义地图规则
	if map_node.has_method("check_custom_move_rules"):
		var current_grid_pos = GameConfig.get_grid_position(position)
		if not map_node.check_custom_move_rules(current_grid_pos, target_grid_pos, Vector2i(direction)):
			return

	# 执行移动
	position = target_pixel_pos
	anim_sprite.play("walk")
	EventBus.player_stepped.emit(target_grid_pos)
