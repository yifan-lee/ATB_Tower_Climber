# res://entities/enemy/bloodshot_eye.gd
extends CharacterBody2D

var anim_sprite: AnimatedSprite2D
var monster_id: String = "bloodshot_eye"

func _ready():
    add_to_group("enemy")
    _setup_sprite()
    _setup_collision()


func _setup_sprite():
    anim_sprite = GameConfig.create_scaled_anim_sprite("res://assets/sprites/enemy/Basic Monster Animations/Bloodshot Eye/blootshot_eye.tres", GameConfig.GRID_SIZE)
    add_child(anim_sprite)


func _setup_collision():
    var collision = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = Vector2(64, 64)
    collision.shape = rect
    add_child(collision)