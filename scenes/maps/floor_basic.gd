# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
	]


	# stairs_config = {
	# 	Vector2i(5, 0): {
	# 		"target_scene": "res://scenes/maps/floor_1.gd",
	# 		"spawn_grid": Vector2i(5, 0)
	# 	},
	# }

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

	# stair_down, stair_up, pedal_switch
	# fragment_blue, fragment_red, fragment_yellow, fragment_white, spirit_stone
	# monster_def_lv1, monster_atk_lv1, monster_spd_lv1, monster_basic_lv1
	# hp_herb_lv1, mp_herb_lv1, 
	# helm_lv1, chestplate_lv1, leggings_lv1, bracers_lv1, boot_lv1, 
	# sword_lv1, blade_lv1, dagger_lv1, shield_lv1, spear_lv1, fan_lv1, staff_lv1