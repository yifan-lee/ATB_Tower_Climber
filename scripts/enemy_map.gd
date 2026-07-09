extends Area2D

@onready var anim = $AnimatedSprite2D # 获取动画节点

func _ready():
    var anim_name = "walk"
    add_to_group("enemy")

    anim.play(anim_name)