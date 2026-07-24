# res://scenes/maps/floor_2.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	config = {"floor": 2, "name": "MAP_FLOOR_NAME_SPD", "desc": "MAP_FLOOR_DESC_SPD"}
	
	map_data = [
		["stair_up       ", "wall           ", "wall           ", "                 ", "               ", "                 ", "wall           ", "               ", "               ", "               ", "           "],
		["hp_herb_lv1", "wall           ", "wall           ", "                 ", "               ", "                 ", "wall           ", "               ", "               ", "               ", "           "],
		["hp_herb_lv1", "wall           ", "wall           ", "                 ", "               ", "monster_basic_lv3", "door_closed    ", "               ", "               ", "               ", "           "],
		["hp_herb_lv1", "wall           ", "wall           ", "wall             ", "wall           ", "wall             ", "wall           ", "               ", "               ", "               ", "           "],
		["               ", "hp_herb_lv1", "monster_def_lv1", "helm_lv1", "monster_def_lv1", "                 ", "wall           ", "wall           ", "wall           ", "wall           ", "wall       "],
		["monster_def_lv3", "wall           ", "wall           ", "wall             ", "wall           ", "                 ", "wall           ", "wall           ", "wall           ", "               ", "stair_down "],
		["               ", "               ", "               ", "                 ", "wall           ", "                 ", "monster_spd_lv1", "spirit_stone", "monster_spd_lv1", "               ", "wall       "],
		["wall           ", "wall           ", "wall           ", "wall             ", "wall           ", "                 ", "wall           ", "wall           ", "wall           ", "               ", "wall       "],
		["hp_herb_lv1  ", "monster_spd_lv1", "hp_herb_lv1 ", "wall             ", "spirit_stone   ", "monster_spd_lv1  ", "hp_herb_lv1    ", "wall           ", "wall           ", "               ", "wall       "],
		["monster_spd_lv1", "hp_herb_lv1   ", "monster_spd_lv1", "                 ", "monster_def_lv1", "sword_lv1        ", "monster_spd_lv1", "wall           ", "monster_spd_lv1", "monster_spd_lv1", "hp_herb_lv1"],
		["hp_herb_lv1   ", "monster_spd_lv1", "hp_herb_lv1", "wall             ", "spirit_stone   ", "monster_def_lv1  ", "hp_herb_lv1    ", "wall           ", "hp_herb_lv1    ", "monster_spd_lv1", "boot_lv1   "],
	]


	stairs_config = {
		Vector2i(10, 5): {
			"target_scene": "res://scenes/maps/floor_1.gd",
			# "spawn_grid": Vector2i(5, 0)
		},
		Vector2i(0, 0): {
			"target_scene": "res://scenes/maps/floor_3.gd",
			# "spawn_grid": Vector2i(8, 10)
		},
	}
	
	items_config = {
		# Vector2i(4, 2): 10
	}
