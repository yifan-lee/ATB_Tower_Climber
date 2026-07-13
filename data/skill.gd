# res://data/skill.gd
extends Resource
class_name Skill

@export var skill_name: String
@export var damage: int
@export var max_cd: int
@export var current_cd: int = 0
@export var description: String

func setup(n: String, dmg: int, cd: int, desc: String) -> Skill:
    skill_name = n
    damage = dmg
    max_cd = cd
    description = desc
    return self