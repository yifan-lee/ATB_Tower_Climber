# res://config/entity_db.gd
extends Node

# 存储所有角色和怪物的数据表
var db: Dictionary = {}

func _ready():
    db['player'] = Stats.new().setup(
        "TooTwo",
        500,
        500,
        200,
        200,
        100,
        100,
        100,
        "res://assets/sprites/player/player.tres",
        # "res://assets/sprites/player/warrior.tres",
        [
            SkillDB.get_skill("basic_atk"),
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
    
    # 配置主角的升级自动学习技能树
    db['player'].level_up_skills = {
        2: "heavy_strike",
        3: "fireball"
    }
    
    var bloodshot = Stats.new().setup_enemy(
        "monster_first",
        "monster_first",
        80,
        0,
        50,
        30,
        52
    )
    # bloodshot.exp_yield = 50
    db['monster_first'] = bloodshot

    var red_cap = Stats.new().setup_enemy(
        "monster_spd_lv1",
        "monster_spd_lv1",
        30,
        0,
        25,
        12,
        115
    )
    db['monster_spd_lv1'] = red_cap

    var stone_troll = Stats.new().setup_enemy(
        "monster_def_lv1",
        "monster_def_lv1",
        200,
        0,
        35,
        105,
        40
    )
    db['monster_def_lv1'] = stone_troll

func get_stats(id: String) -> Stats:
    return db.get(id)