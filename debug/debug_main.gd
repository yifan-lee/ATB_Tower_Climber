extends "res://scenes/main.gd"

@export_category("Map Settings")
@export_file("*.gd") var starting_map: String = "res://scenes/maps/floor_2.gd"
@export var start_pos: Vector2i = Vector2i(5, 5)

@export_category("Player Stats")
@export var debug_level: int = 10
@export var debug_hp: int = 500
@export var debug_mp: int = 250
@export var debug_atk: int = 100
@export var debug_def: int = 100
@export var debug_spd: int = 100
@export var debug_exp: int = 0
@export var debug_stat_points: int = 0

@export_category("Inventory & Skills")
@export var debug_inventory: Dictionary = {
	"spirit_stone": 50,
	"fragment_red": 10,
	"sword_level5": 1,
	"hp_herb": 99
}
@export var debug_skills: Array[String] = ["fireball", "heavy_strike", "one_hit"]

@export_category("Equipment")
@export var equip_head: String = ""
@export var equip_chest: String = ""
@export var equip_legs: String = ""
@export var equip_feet: String = ""
@export var equip_left_hand: String = "sword_level5"
@export var equip_right_hand: String = ""
@export var equip_accessory: String = ""

func _load_initial_scenes():
	# 1. 强制覆盖玩家初始数据 (EntityDB 是全局共享的，在 main 加载前修改即可)
	var player_stats = EntityDB.get_stats("player")
	if player_stats:
		player_stats.level = debug_level
		player_stats.max_hp = debug_hp
		player_stats.current_hp = debug_hp
		player_stats.max_mp = debug_mp
		player_stats.current_mp = debug_mp
		player_stats.atk = debug_atk
		player_stats.def = debug_def
		player_stats.spd = debug_spd
		player_stats.exp = debug_exp
		player_stats.stat_points = debug_stat_points
		
		# 清空并覆盖背包
		player_stats.inventory.clear()
		for item_id in debug_inventory.keys():
			player_stats.inventory[item_id] = debug_inventory[item_id]
			
		# 清空并覆盖技能
		player_stats.skills.clear()
		for skill_id in debug_skills:
			var s = SkillDB.get_skill(skill_id)
			if s != null:
				player_stats.skills.append(s)
				
		# 覆盖装备
		var ItemClass = load("res://data/item.gd")
		var equips_map = {
			ItemClass.EquipSlot.HEAD: equip_head,
			ItemClass.EquipSlot.CHEST: equip_chest,
			ItemClass.EquipSlot.LEGS: equip_legs,
			ItemClass.EquipSlot.FEET: equip_feet,
			ItemClass.EquipSlot.LEFT_HAND: equip_left_hand,
			ItemClass.EquipSlot.RIGHT_HAND: equip_right_hand,
			ItemClass.EquipSlot.ACCESSORY: equip_accessory
		}
		
		# 清空旧装备
		for slot in player_stats.equipment.keys():
			player_stats.equipment[slot] = null
			
		# 装上新装备
		for slot in equips_map:
			var equip_id = equips_map[slot]
			if equip_id != "":
				var item = ItemDB.get_item(equip_id)
				if item != null:
					player_stats.equipment[slot] = item
	
	# 2. 调用父类初始化（会加载 UI、默认第一层和玩家）
	super._load_initial_scenes()
	
	# 3. 强制跳转到指定的 debug 楼层，并设置起始坐标
	_on_map_change_requested(starting_map, start_pos)
