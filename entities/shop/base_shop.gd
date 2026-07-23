# res://entities/shop/base_shop.gd
extends StaticBody2D
class_name BaseShop

var anim_sprite: AnimatedSprite2D
var shop_id: String

func setup(id: String):
	shop_id = id
	var stats = EntityDB.get_stats(shop_id)
	if not stats:
		push_error("Cannot find shop in EntityDB: " + shop_id)
		return
		
	# 自动加载数据库中配置的专属动画贴图
	anim_sprite = GameConfig.create_scaled_anim_sprite(stats.anim_path, GameConfig.GRID_SIZE)
	add_child(anim_sprite)

func _ready():
	add_to_group("shop")
	_setup_collision()

func _setup_collision():
	var collision = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	# 占满一个格子
	rect.size = Vector2(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE)
	collision.shape = rect
	add_child(collision)
