# res://core/game_rules.gd
class_name GameRules

const STATUE_EXCHANGE_COST_RED = 1
const STATUE_EXCHANGE_GAIN_ATK = 5
const STATUE_EXCHANGE_COST_BLUE = 1
const STATUE_EXCHANGE_GAIN_SPD = 5
const STATUE_EXCHANGE_COST_YELLOW = 1
const STATUE_EXCHANGE_GAIN_DEF = 5

const BASE_PLAYER_CP: float = 100.0
const CP_GROWTH_PER_LEVEL: float = 0.05

const MULTIPLIER_MOB: float = 0.5 # 普通小怪战力是同级玩家的 45%
const MULTIPLIER_ELITE: float = 0.75 # 精英怪 75%
const MULTIPLIER_BOSS: float = 1.25 # Boss 135%
const MULTIPLIER_HERO: float = 1.00 # 英雄 100%


const STAT_POINTS_PER_LEVEL: int = 10

const ATB_SPEED_DOM: float = 400.0
const ATB_SPEED_CONSTANT: float = 400.0
const ATB_SPEED_LOWERBOUND: float = 0.1

const STAT_ADD_RATIO_HP: int = 10
const STAT_ADD_RATIO_MP: int = 5
const STAT_ADD_RATIO_ATK: int = 1
const STAT_ADD_RATIO_DEF: int = 1
const STAT_ADD_RATIO_SPD: int = 1

const RECOVER_ON_LEVEL_UP: bool = false

const EXP_YIELD_DIVISOR: float = 10.0
const LEVEL_UP_EXP_BASE: int = 50
const LEVEL_UP_EXP_MULTIPLIER: int = 10

static func calculate_cp(hp: int, mp: int, atk: int, def: int, spd: int) -> float:
	return (
		float(atk) / STAT_ADD_RATIO_ATK +
		float(def) / STAT_ADD_RATIO_DEF +
		float(spd) / STAT_ADD_RATIO_SPD +
		float(hp) / STAT_ADD_RATIO_HP +
		float(mp) / STAT_ADD_RATIO_MP
	)

static func _reverse_calculate_level(target_cp: float, rarity_multiplier: float) -> int:
	var base_rarity_cp = BASE_PLAYER_CP * rarity_multiplier
	var level_float = ((target_cp / base_rarity_cp) - 1.0) / CP_GROWTH_PER_LEVEL + 1.0
	return maxi(1, roundi(level_float))

static func evaluate_monster(hp: int, mp: int, atk: int, def: int, spd: int) -> Dictionary:
	var cp = calculate_cp(hp, mp, atk, def, spd)
	return {
		"total_cp": cp,
		"as_hero_level": _reverse_calculate_level(cp, MULTIPLIER_HERO),
		"as_mob_level": _reverse_calculate_level(cp, MULTIPLIER_MOB),
		"as_elite_level": _reverse_calculate_level(cp, MULTIPLIER_ELITE),
		"as_boss_level": _reverse_calculate_level(cp, MULTIPLIER_BOSS)
	}

# 怪物掉落的经验值
static func get_monster_exp_yield(hp: int, mp: int, atk: int, def: int, spd: int) -> int:
	var cp = calculate_cp(hp, mp, atk, def, spd)
	return maxi(1, roundi(cp / EXP_YIELD_DIVISOR))

# 玩家升级需要的经验
static func get_level_up_exp(current_level: int) -> int:
	return LEVEL_UP_EXP_BASE + current_level * LEVEL_UP_EXP_MULTIPLIER

# 伤害公式
static func calculate_damage(atk: int, def: int, skill_damage: int) -> float:
	return max(1, atk / 10.0 * skill_damage * (100.0 / (100.0 + def)))

# 速度公式 
static func get_atb_speed(speed: float) -> float:
	return (ATB_SPEED_CONSTANT + speed) / ATB_SPEED_DOM
