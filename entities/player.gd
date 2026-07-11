# res://entities/player.gd
extends CharacterBody2D

# 记录当前面朝的方向，默认向下
# var facing_direction = "down"
var anim_sprite: AnimatedSprite2D

func _ready():
    _setup_sprite()
    _setup_collision()

func _setup_sprite():
    anim_sprite = AnimatedSprite2D.new()
    # 加载你在编辑器切好的 4x8 动画资源
    anim_sprite.sprite_frames = load("res://assets/sprites/player/blonde_man_animations.tres")
    
    # 放大 4 倍以填满网格
    anim_sprite.scale = Vector2(2, 2)
    
    # 向上偏移贴图，使得角色的脚底（贴图底部）与玩家所在格子的底部对齐
    # 避免贴图向下超出碰撞体而插进墙壁或者被 UI 裁剪掉
    # anim_sprite.offset = Vector2(0, -8)
    
    add_child(anim_sprite)
    anim_sprite.play("idle")

func _setup_collision():
    var collision = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    # 碰撞体设置为 60x60（或者稍微小于 64 的尺寸），留出容错空间防止卡墙
    rect.size = Vector2(60, 60)
    collision.shape = rect
    add_child(collision)

func _physics_process(_delta):
    var direction = Vector2.ZERO
    
    # 只监听键盘的单次按下
    if Input.is_action_just_pressed("ui_right"):
        direction = Vector2.RIGHT
        # facing_direction = "right"
    elif Input.is_action_just_pressed("ui_left"):
        direction = Vector2.LEFT
        # facing_direction = "left"
    elif Input.is_action_just_pressed("ui_down"):
        direction = Vector2.DOWN
        # facing_direction = "down"
    elif Input.is_action_just_pressed("ui_up"):
        direction = Vector2.UP
        # facing_direction = "up"
        
    if direction != Vector2.ZERO:
        _try_move(direction)

func _try_move(direction: Vector2):
    var current_transform = Transform2D(0, position)
    
    # 直接调用全局配置中的网格大小计算真实位移距离 [cite: 12]
    var motion = direction * GameConfig.GRID_SIZE
    
    # 探测前方是否撞墙 [cite: 33]
    if not test_move(current_transform, motion):
        # 没有撞墙，执行瞬间移动
        position += motion
        anim_sprite.play("walk")
    else:
        # 撞墙了，播放待机动画
        anim_sprite.play("idle")