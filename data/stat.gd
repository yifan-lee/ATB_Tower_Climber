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
@export var inventory: Dictionary = {}
@export var equipment: Dictionary = {
	Item.EquipSlot.HEAD: null,
	Item.EquipSlot.CHEST: null,
	Item.EquipSlot.LEGS: null,
	Item.EquipSlot.FEET: null,
	Item.EquipSlot.LEFT_HAND: null,
	Item.EquipSlot.RIGHT_HAND: null,
	Item.EquipSlot.ACCESSORY: null
}

func setup(n: String, hp: int, chp: int, mp: int, cmp: int, a: int, d: int, s: int, anim: String, sk: Array[Skill], inv: Dictionary = {}) -> Stats:
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
	inventory = inv
	return self

func get_total_max_hp() -> int:
	var total = max_hp
	for slot in equipment:
		if equipment[slot] != null:
			total += equipment[slot].effect_hp
	return total

func get_total_max_mp() -> int:
	var total = max_mp
	for slot in equipment:
		if equipment[slot] != null:
			total += equipment[slot].effect_mp
	return total

func get_total_atk() -> int:
	var total = atk
	for slot in equipment:
		if equipment[slot] != null:
			total += equipment[slot].effect_atk
	return total

func get_total_def() -> int:
	var total = def
	for slot in equipment:
		if equipment[slot] != null:
			total += equipment[slot].effect_def
	return total

func get_total_spd() -> int:
	var total = spd
	for slot in equipment:
		if equipment[slot] != null:
			total += equipment[slot].effect_spd
	return total
