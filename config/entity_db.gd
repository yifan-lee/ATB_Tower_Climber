# res://config/entity_db.gd
extends Node

# 存储所有角色和怪物的数据表
var db: Dictionary = {}

func _ready():
    db['player'] = Stats.new().setup(
        "TooTwo",
        200,
        200,
        100,
        100,
        20,
        20,
        20,
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
        3: "heavy_strike",
        5: "fireball"
    }

    # 商店实体配置
    var shop_stats = Stats.new().setup(
        "shop", 1, 1, 0, 0, 0, 0, 0,
        "res://assets/sprites/map/shop.tres", [], {}, "as_mob_level"
    )
    db['shop'] = shop_stats
    
    
    var monster_first = Stats.new().setup_enemy(
        "monster_first",
        "monster_first",
        40,
        5,
        7,
        3,
        10
    )
    # bloodshot.exp_yield = 50
    db['monster_first'] = monster_first

    var monster_spd_lv1 = Stats.new().setup_enemy(
        "monster_spd_lv1",
        "monster_spd_lv1",
        80,
        10,
        46,
        30,
        114
    )
    db['monster_spd_lv1'] = monster_spd_lv1

    var monster_spd_lv2 = Stats.new().setup_enemy(
        "monster_spd_lv2",
        "monster_spd_lv2",
        1000,
        1000,
        1000,
        1000,
        1000
    )
    db['monster_spd_lv2'] = monster_spd_lv2

    var monster_spd_lv3 = Stats.new().setup_enemy(
        "monster_spd_lv3",
        "monster_spd_lv3",
        10000,
        10000,
        10000,
        10000,
        10000
    )
    db['monster_spd_lv3'] = monster_spd_lv3

    var monster_def_lv1 = Stats.new().setup_enemy(
        "monster_def_lv1",
        "monster_def_lv1",
        110,
        10,
        30,
        120,
        37
    )
    db['monster_def_lv1'] = monster_def_lv1

    var monster_def_lv2 = Stats.new().setup_enemy(
        "monster_def_lv2",
        "monster_def_lv2",
        1000,
        1000,
        1000,
        1000,
        1000
    )
    db['monster_def_lv2'] = monster_def_lv2


    var monster_def_lv3 = Stats.new().setup_enemy(
        "monster_def_lv3",
        "monster_def_lv3",
        10000,
        10000,
        10000,
        10000,
        10000
    )
    db['monster_def_lv3'] = monster_def_lv3

    var monster_atk_lv1 = Stats.new().setup_enemy(
        "monster_atk_lv1",
        "monster_atk_lv1",
        80,
        10,
        80,
        60,
        50,
        "as_mob_level",
        "",
        [SkillDB.get_skill("basic_atk"), SkillDB.get_skill("heavy_strike")]
    )
    db['monster_atk_lv1'] = monster_atk_lv1

    var monster_atk_lv2 = Stats.new().setup_enemy(
        "monster_atk_lv2",
        "monster_atk_lv2",
        1000,
        1000,
        1000,
        1000,
        1000
    )
    db['monster_atk_lv2'] = monster_atk_lv2


    var monster_atk_lv3 = Stats.new().setup_enemy(
        "monster_atk_lv3",
        "monster_atk_lv3",
        10000,
        10000,
        10000,
        10000,
        10000
    )
    db['monster_atk_lv3'] = monster_atk_lv3

    var monster_basic_lv1 = Stats.new().setup_enemy(
        "monster_basic_lv1",
        "monster_basic_lv1",
        180,
        10,
        100,
        100,
        95,
        "as_elite_level",
        "",
        [SkillDB.get_skill("basic_atk"), SkillDB.get_skill("heavy_strike")]
    )
    db['monster_basic_lv1'] = monster_basic_lv1

    var monster_basic_lv2 = Stats.new().setup_enemy(
        "monster_basic_lv2",
        "monster_basic_lv2",
        1000,
        1000,
        1000,
        1000,
        1000
    )
    db['monster_basic_lv2'] = monster_basic_lv2


    var monster_basic_lv3 = Stats.new().setup_enemy(
        "monster_basic_lv3",
        "monster_basic_lv3",
        10000,
        10000,
        10000,
        10000,
        10000
    )
    db['monster_basic_lv3'] = monster_basic_lv3

    var boss_lv1 = Stats.new().setup_enemy(
        "boss_lv1",
        "boss_lv1",
        10000,
        10000,
        10000,
        10000,
        10000
    )
    db['boss_lv1'] = boss_lv1

func get_stats(id: String) -> Stats:
    return db.get(id)