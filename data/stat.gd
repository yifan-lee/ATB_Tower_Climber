# res://data/stats.gd
extends Resource
class_name Stats

@export var entity_name: String
@export var max_hp: int = 500
@export var atk: int = 100
@export var def: int = 100
@export var spd: int = 100
@export var anim_path: String
@export var skills: Array[String] = ['']


func setup(n: String, hp: int, a: int, d: int, s: int, anim: String, sk: Array[String]) -> Stats:
	entity_name = n
	max_hp = hp
	atk = a
	def = d
	spd = s
	anim_path = anim
	skills = sk
	return self
