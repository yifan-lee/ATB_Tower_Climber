# res://config/entity_db.gd
extends Node

# 存储所有角色和怪物的数据表
var db: Dictionary = {}

func _ready():
    db['player'] = Stats.new().setup(
        "TooTwo",
        500,
        100,
        100,
        100,
        "res://assets/sprites/player/blonde_man_animations.tres",
        [
            ''
        ]
    )
    
    db['bloodshot_eye'] = Stats.new().setup(
        "BloodshotEye",
        100,
        50,
        50,
        60,
        "res://assets/sprites/enemy/Basic Monster Animations/Bloodshot Eye/blootshot_eye.tres",
        [
            ''
        ]
    )

func get_stats(id: String) -> Stats:
    return db.get(id)