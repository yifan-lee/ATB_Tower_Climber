# res://config/skill_db.gd
extends Node

# 存储所有角色和怪物的数据表
var db: Dictionary = {}

func _ready():
	db["basic_atk"] = Skill.new().setup(
		"basic_atk", "SKILL_BASIC_ATK_NAME", 100, 0, 0, "SKILL_BASIC_ATK_DESC"
	)
	db["heavy_strike"] = Skill.new().setup(
		"heavy_strike", "SKILL_HEAVY_NAME", 150, 3, 0, "SKILL_HEAVY_DESC"
	)
	db["fireball"] = Skill.new().setup(
		"fireball", "SKILL_FIREBALL_NAME", 200, 8, 15, "SKILL_FIREBALL_DESC"
	)
	db["one_hit"] = Skill.new().setup(
		"one_hit", "SKILL_ONE_HIT_NAME", 999999, 0, 0, "SKILL_ONE_HIT_DESC"
	)

func get_skill(id: String) -> Skill:
	if db.has(id):
		return db[id].duplicate(true)
	else:
		push_error("找不到技能 ID: " + id)
		return null
