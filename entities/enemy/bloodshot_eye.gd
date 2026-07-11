# res://entities/enemy/bloodshot_eye.gd
extends CharacterBody2D

var anim_sprite: AnimatedSprite2D

func _ready():
    _setup_sprite()
    _setup_collision()


func _setup_sprite():
    anim_sprite = AnimatedSprite2D.new()
    # 加载你在编辑器切好的 4x8 动画资源
    anim_sprite.sprite_frames = load("res://assets/sprites/enemy/Basic Monster Animations/Bloodshot Eye/blootshot_eye.tres")
    
    # 放大 4 倍以填满网格
    anim_sprite.scale = Vector2(2, 2)
    
    add_child(anim_sprite)
    anim_sprite.play("idle")


func _setup_collision():
    var collision = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = Vector2(64, 64)
    collision.shape = rect
    add_child(collision)