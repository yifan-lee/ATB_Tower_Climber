# res://data/skill.gd
extends Resource
class_name Skill

@export var skill_name: String
@export var damage: int
@export var max_cd: float
@export var current_cd: float = 0.0
@export var description: String

func setup(n: String, dmg: int, cd: float, desc: String) -> Skill:
    skill_name = n
    damage = dmg
    max_cd = cd
    description = desc
    return self