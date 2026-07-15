# res://entities/enemy/base_enemy.gd
extends CharacterBody2D

var anim_sprite: AnimatedSprite2D
var monster_id: String

func setup(id: String):
	monster_id = id
	var stats = EntityDB.get_stats(monster_id)
	if not stats:
		push_error("Cannot find monster in EntityDB: " + monster_id)
		return
		
	# 自动加载数据库中配置的专属动画贴图
	anim_sprite = GameConfig.create_scaled_anim_sprite(stats.anim_path, GameConfig.GRID_SIZE)
	add_child(anim_sprite)

func _ready():
	add_to_group("enemy")
	_setup_collision()

func _setup_collision():
	var collision = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	# 占满一个格子
	rect.size = Vector2(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE)
	collision.shape = rect
	add_child(collision)
