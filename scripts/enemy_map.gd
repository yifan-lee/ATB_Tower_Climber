# extends Area2D

# @onready var anim = $AnimatedSprite2D # 获取动画节点

# func _ready():
#     var anim_name = "walk"
#     add_to_group("enemy")

#     anim.play(anim_name)


extends Area2D
class_name EnemyMapNode # 给它起个类名，方便玩家识别

# 只要把 goblin.tres 拖到这个变量里就行了
@export var stats: CharacterStats

func _ready():
    # 初始化贴图和动画
    add_to_group("enemy")
    if stats and stats.sprite_frames:
        $AnimatedSprite2D.sprite_frames = stats.sprite_frames
        $AnimatedSprite2D.play("idle")