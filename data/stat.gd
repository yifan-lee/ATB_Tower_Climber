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
	Item.EquipSlot.ARMS: null,
	Item.EquipSlot.LEFT_HAND: null,
	Item.EquipSlot.RIGHT_HAND: null,
	Item.EquipSlot.ACCESSORY: null,
}

@export var level_up_skills: Dictionary = {}

@export var level: int = 1
@export var exp: int = 0
@export var max_exp: int = 100
@export var stat_points: int = 0
@export var exp_yield: int = -1 # -1 means use formula based on level

func setup(
	n: String, hp: int, chp: int, mp: int, cmp: int, a: int, d: int, s: int,
	anim: String, sk: Array[Skill], inv: Dictionary = {},
	entity_type: String = "as_mob_level",
) -> Stats:
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
	var result = GameRules.evaluate_monster(hp, mp, a, d, s)
	level = result[entity_type]
	max_exp = GameRules.get_level_up_exp(level)
	return self

func setup_enemy(
	id: String,
	n: String,
	hp: int,
	mp: int,
	a: int,
	d: int,
	s: int,
	entity_type: String = "as_mob_level",
	anim: String = "",
	sk: Array = []
) -> Stats:
	entity_name = n
	max_hp = hp
	current_hp = hp
	max_mp = mp
	current_mp = mp
	atk = a
	def = d
	spd = s
	
	if anim == "":
		anim_path = "res://assets/sprites/enemy/" + id + ".tres"
	else:
		anim_path = anim
		
	if sk.is_empty():
		skills = [SkillDB.get_skill("basic_atk")]
	else:
		# Convert untyped Array to Array[Skill]
		var typed_skills: Array[Skill] = []
		for skill in sk:
			typed_skills.append(skill as Skill)
		skills = typed_skills
		
	inventory = {}
	var result = GameRules.evaluate_monster(hp, mp, a, d, s)
	level = result[entity_type]
	max_exp = GameRules.get_level_up_exp(level)
	return self


func get_exp_yield() -> int:
	if exp_yield != -1:
		return exp_yield
	return GameRules.get_monster_exp_yield(max_hp, max_mp, atk, def, spd)

# Future interface for recovering on level up (currently disabled by user request)
func recover_on_level_up():
	if GameRules.RECOVER_ON_LEVEL_UP:
		current_hp = get_total_max_hp()
		current_mp = get_total_max_mp()

func gain_exp(amount: int) -> bool:
	exp += amount
	var leveled_up = false
	while exp >= max_exp:
		exp -= max_exp
		level += 1
		max_exp = GameRules.get_level_up_exp(level)
		stat_points += GameRules.STAT_POINTS_PER_LEVEL
		leveled_up = true
		recover_on_level_up()
		
		# Check for new skills
		if level_up_skills.has(level):
			var skill_id = level_up_skills[level]
			var already_has = false
			for s in skills:
				if s.id == skill_id:
					already_has = true
					break
			if not already_has:
				var new_skill = SkillDB.get_skill(skill_id)
				if new_skill:
					skills.append(new_skill)
					EventBus.show_system_message.emit(["MSG_LEARN_SKILL", new_skill.skill_name])
					
	return leveled_up

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
