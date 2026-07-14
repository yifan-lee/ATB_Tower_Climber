# res://config/entity_db.gd
extends Node

# 存储所有角色和怪物的数据表
var db: Dictionary = {}

func _ready():
    db['player'] = Stats.new().setup(
        "TooTwo",
        10000,
        10000,
        500,
        500,
        100,
        100,
        100,
        "res://assets/sprites/player/blonde_man_animations.tres",
        [
            SkillDB.get_skill("basic_atk"),
            SkillDB.get_skill("heavy_strike"),
            SkillDB.get_skill("fireball"),
            SkillDB.get_skill("one_hit"),
        ],
        {
            # "hp_potion": 5,
            # "mp_potion": 3,
            # "iron_sword": 1,
            # "iron_helm": 1,
            # "tree_branch": 1,
            # "jy_sword": 1
        }
    )
    
    db['bloodshot_eye'] = Stats.new().setup(
        "BloodshotEye",
        1000,
        1000,
        0,
        0,
        50,
        50,
        60,
        "res://assets/sprites/enemy/Basic Monster Animations/Bloodshot Eye/blootshot_eye.tres",
        [
            SkillDB.get_skill("basic_atk"),
        ],
        {}, # Empty inventory
        5 # Level 5
    )

func get_stats(id: String) -> Stats:
    return db.get(id)