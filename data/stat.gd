# res://data/stats.gd
extends Resource
class_name Stats

@export var entity_name: String
@export var max_hp: int = 500
@export var current_hp: int = 500
@export var max_mp: int = 500
@export var current_mp: int = 500
@export var atk: int = 100
@export var def: int = 100
@export var spd: int = 100
@export var anim_path: String
@export var skills: Array[Skill]


func setup(n: String, hp: int, chp: int, mp: int, cmp: int, a: int, d: int, s: int, anim: String, sk: Array[Skill]) -> Stats:
	entity_name = n
	max_hp = hp
	current_hp = chp
	max_mp = mp
	current_mp = cmp
	atk = a
	def = d
	spd = s
	anim_path = anim
	skills = sk
	return self
