# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["stair_down       ", "                 ", "wall             ", "wall             ", "wall             ", "wall             ", "wall             ", "wall", "wall", "wall", "wall             "],
		["wall             ", "                 ", "monster_basic_lv1", "spirit_stone     ", "monster_basic_lv1", "                 ", "wall             ", "    ", "    ", "    ", "wall             "],
		["wall             ", "wall             ", "wall             ", "wall             ", "wall             ", "door_closed      ", "wall             ", "    ", "    ", "    ", "wall             "],
		["                 ", "                 ", "monster_basic_lv1", "monster_basic_lv1", "monster_basic_lv1", "                 ", "wall             ", "    ", "    ", "    ", "wall             "],
		["spirit_stone     ", "wall             ", "wall             ", "wall             ", "wall             ", "wall             ", "wall             ", "wall", "wall", "wall", "wall             "],
		["                 ", "hp_herb_lv1      ", "mp_herb_lv1      ", "                 ", "monster_basic_lv1", "                 ", "                 ", "wall", "    ", "wall", "spirit_stone     "],
		["wall             ", "wall             ", "wall             ", "monster_basic_lv1", "                 ", "                 ", "monster_basic_lv1", "wall", "    ", "wall", "monster_basic_lv1"],
		["helm_lv1         ", "hp_herb_lv1      ", "wall             ", "                 ", "                 ", "monster_basic_lv1", "                 ", "    ", "    ", "    ", "                 "],
		["mp_herb_lv1      ", "monster_basic_lv1", "wall             ", "wall             ", "door_closed      ", "wall             ", "wall             ", "wall", "    ", "wall", "monster_basic_lv1"],
		["monster_basic_lv1", "                 ", "                 ", "                 ", "monster_basic_lv1", "spirit_stone     ", "monster_basic_lv1", "wall", "    ", "wall", "monster_basic_lv1"],
		["                 ", "                 ", "                 ", "                 ", "spirit_stone     ", "monster_basic_lv1", "pedal_switch     ", "wall", "wall", "wall", "spirit_stone     "],
	]


	stairs_config = {
		Vector2i(0, 0): {
			"target_scene": "res://scenes/maps/floor_2.gd",
		},
		Vector2i(8, 10): {
			"target_scene": "res://scenes/maps/floor_4.gd",
		},
	}

	triggers_config = {
		Vector2i(6, 10): [ # 用中括号 [] 包裹起来，变成一个数组（Array）
			{
				"target_grid": Vector2i(8, 10),
				"target_new_type": "stair_up"
			},
		]
	}
	
	doors_config = {
		Vector2i(5, 2): {
			"cost": 5,
			"monster": "monster_basic_lv1"
		},
		Vector2i(4, 8): {
			"cost": 10,
			"monster": "monster_atk_lv1"
		}
	}

	# stair_down, stair_up, pedal_switch, door_closed
	# fragment_blue, fragment_red, fragment_yellow, fragment_white, spirit_stone
	# monster_def_lv1, monster_atk_lv1, monster_spd_lv1, monster_basic_lv1
	# hp_herb_lv1, mp_herb_lv1, 
	# helm_lv1, chestplate_lv1, leggings_lv1, bracers_lv1, boot_lv1, 
	# sword_lv1, blade_lv1, dagger_lv1, shield_lv1, spear_lv1, fan_lv1, staff_lv1