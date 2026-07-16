# res://config/entity_db.gd
extends Node

# 存储所有角色和怪物的数据表
var db: Dictionary = {}

func _ready():
    db['player'] = Stats.new().setup(
        "TooTwo",
        100,
        100,
        50,
        50,
        100,
        100,
        100,
        "res://assets/sprites/player/blonde_man_animations.tres",
        # "res://assets/sprites/player/warrior.tres",
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
        },
        'as_hero_level'
    )
    
    var bloodshot = Stats.new().setup(
        "BloodshotEye",
        80,
        80,
        0,
        0,
        50,
        30,
        52,
        "res://assets/sprites/enemy/blootshot_eye.tres",
        [
            SkillDB.get_skill("basic_atk"),
        ],
        {}, # Empty inventory
        'as_mob_level'
    )
    bloodshot.exp_yield = 50
    db['bloodshot_eye'] = bloodshot

    var red_cap = Stats.new().setup(
        "RedCap",
        40,
        40,
        0,
        0,
        45,
        11,
        80,
        "res://assets/sprites/enemy/red_cap.tres",
        [
            SkillDB.get_skill("basic_atk"),
        ],
        {}, # Empty inventory
        'as_mob_level'
    )
    db['red_cap'] = red_cap

    var stone_troll = Stats.new().setup(
        "RedCap",
        120,
        120,
        0,
        0,
        38,
        60,
        30,
        "res://assets/sprites/enemy/stone_troll.tres",
        [
            SkillDB.get_skill("basic_atk"),
        ],
        {}, # Empty inventory
        'as_mob_level'
    )
    db['stone_troll'] = stone_troll

func get_stats(id: String) -> Stats:
    return db.get(id)