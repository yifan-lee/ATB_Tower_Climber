# res://scenes/maps/floor_5.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	config = {"floor": 5, "name": "MAP_FLOOR_NAME_BOSS1", "desc": "MAP_FLOOR_DESC_BOSS1"}
	map_data = [
		["chestplate_lv2   ", "monster_basic_lv1", "fragment_red     ", "monster_basic_lv1", "fragment_red     ", "door_closed", "fragment_red", "monster_basic_lv1", "fragment_red     ", "monster_basic_lv1", "leggings_lv2     "],
		["monster_basic_lv1", "wall             ", "wall             ", "wall             ", "wall             ", "wall       ", "wall        ", "wall             ", "wall             ", "wall             ", "monster_basic_lv1"],
		["fragment_blue    ", "wall             ", "sword_lv2        ", "monster_basic_lv1", "spirit_stone     ", "door_closed", "spirit_stone", "monster_basic_lv1", "sword_lv2        ", "wall             ", "fragment_yellow  "],
		["monster_basic_lv1", "wall             ", "monster_basic_lv1", "wall             ", "wall             ", "wall       ", "wall        ", "wall             ", "monster_basic_lv1", "wall             ", "monster_basic_lv1"],
		["fragment_blue    ", "wall             ", "spirit_stone     ", "wall             ", "boss_lv1         ", "stair_up   ", "            ", "wall             ", "mp_herb_lv2", "wall             ", "fragment_yellow  "],
		["door_closed      ", "wall             ", "door_closed      ", "wall             ", "                 ", "           ", "            ", "wall             ", "door_closed      ", "wall             ", "door_closed      "],
		["fragment_blue    ", "wall             ", "spirit_stone     ", "wall             ", "                 ", "           ", "            ", "wall             ", "mp_herb_lv2", "wall             ", "fragment_yellow  "],
		["monster_basic_lv1", "wall             ", "monster_basic_lv1", "wall             ", "wall             ", "           ", "            ", "wall             ", "monster_basic_lv1", "wall             ", "monster_basic_lv1"],
		["fragment_blue    ", "wall             ", "boot_lv2         ", "monster_basic_lv1", "hp_herb_lv2      ", "wall       ", "mp_herb_lv2", "monster_basic_lv1", "mp_herb_lv2", "wall             ", "fragment_yellow  "],
		["monster_basic_lv1", "wall             ", "wall             ", "wall             ", "monster_basic_lv1", "wall       ", "wall        ", "wall             ", "wall             ", "wall             ", "monster_basic_lv1"],
		["helm_lv2         ", "monster_basic_lv1", "stair_down       ", "wall             ", "hp_herb_lv2      ", "door_closed", "hp_herb_lv2 ", "monster_basic_lv1", "hp_herb_lv2      ", "monster_basic_lv1", "bracers_lv2      "],
	]


	stairs_config = {
		Vector2i(2, 10): {
			"target_scene": "res://scenes/maps/floor_4.gd",
		},
		Vector2i(5, 4): {
			"target_scene": "res://scenes/maps/floor_6.gd",
		},
	}
	
	entities_size_config = {
		Vector2i(4, 4): Vector2i(3, 3)
	}

	doors_config = {
		Vector2i(0, 5): {
			"cost": 5,
			"monster": "monster_basic_lv1"
		},
		Vector2i(5, 0): {
			"cost": 10,
			"monster": "monster_atk_lv1"
		},
		Vector2i(10, 5): {
			"cost": 10,
			"monster": "monster_atk_lv1"
		},
		Vector2i(5, 10): {
			"cost": 10,
			"monster": "monster_atk_lv1"
		},
		Vector2i(2, 5): {
			"cost": 10,
			"monster": "monster_atk_lv1"
		},
		Vector2i(5, 2): {
			"cost": 10,
			"monster": "monster_atk_lv1"
		},
		Vector2i(8, 5): {
			"cost": 10,
			"monster": "monster_atk_lv1"
		},
	}

	# triggers_config = {
	# 	Vector2i(1, 5): [
	# 		{
	# 			"type": "change_tile",
	# 			"target_grid": Vector2i(10, 5),
	# 			"target_new_type": "stair_up",
	# 			"one_shot": true
	# 		},
	# 		{
	# 			"type": "change_tile",
	# 			"target_grid": Vector2i(5, 10),
	# 			"target_new_type": "wall",
	# 			"one_shot": true
	# 		},
	# 		{
	# 			"type": "give_exp",
	# 			"amount": 10,
	# 			"one_shot": true
	# 		}
	# 	]
	# }

	# stair_down, stair_up, pedal_switch, door_closed, door_opened
	# fragment_blue, fragment_red, fragment_yellow, fragment_white, spirit_stone
	# monster_def_lv1, monster_atk_lv1, monster_spd_lv1, monster_basic_lv1
	# hp_herb_lv1, mp_herb_lv1, 
	# helm_lv1, chestplate_lv1, leggings_lv1, bracers_lv1, boot_lv1, 
	# sword_lv1, blade_lv1, dagger_lv1, shield_lv1, spear_lv1, fan_lv1, staff_lv1