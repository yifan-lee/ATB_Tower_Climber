# res://data/skill.gd
extends Resource
class_name Skill

@export var id: String
@export var skill_name: String
@export var damage: int
@export var max_cd: float
@export var mana_cost: int = 0
@export var current_cd: float = 0.0
@export var description: String

func setup(i: String, n: String, dmg: int, cd: float, mc: int, desc: String) -> Skill:
    id = i
    skill_name = n
    damage = dmg
    max_cd = cd
    mana_cost = mc
    description = desc
    return self