# res://config/skill_db.gd
extends Node

# 存储所有角色和怪物的数据表
var db: Dictionary = {}

func _ready():
    db['normal_attack'] = Skill.new().setup(
        "normal_attack",
        50,
        0.0
    )

func get_skill(id: String) -> Skill:
    return db.get(id)