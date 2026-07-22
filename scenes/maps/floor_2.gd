# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	floor_name_key = "MAP_FLOOR_2_NAME"
	floor_desc_key = "MAP_FLOOR_2_DESC"
	
	map_data = [
		["stair_up       ", "               ", "wall           ", "    ", "               ", "                 ", "wall           ", "               ", "               ", "               ", "           "],
		["               ", "               ", "wall           ", "    ", "               ", "                 ", "wall           ", "               ", "               ", "               ", "           "],
		["               ", "               ", "wall           ", "    ", "               ", "monster_basic_lv3", "door_closed    ", "               ", "               ", "               ", "           "],
		["               ", "               ", "wall           ", "wall", "wall           ", "wall             ", "wall           ", "               ", "               ", "               ", "           "],
		["               ", "               ", "               ", "    ", "               ", "                 ", "wall           ", "wall           ", "wall           ", "wall           ", "wall       "],
		["monster_def_lv3", "wall           ", "wall           ", "wall", "wall           ", "                 ", "wall           ", "wall           ", "wall           ", "               ", "stair_down "],
		["               ", "               ", "               ", "    ", "wall           ", "                 ", "monster_def_lv1", "monster_spd_lv1", "monster_spd_lv1", "               ", "wall       "],
		["wall           ", "wall           ", "wall           ", "wall", "wall           ", "                 ", "wall           ", "wall           ", "wall           ", "               ", "wall       "],
		["fragment_blue  ", "monster_def_lv1", "fragment_white ", "wall", "spirit_stone   ", "monster_def_lv1  ", "hp_herb        ", "wall           ", "wall           ", "               ", "wall       "],
		["monster_def_lv1", "spirit_stone   ", "monster_def_lv1", "    ", "monster_def_lv1", "sword_level1     ", "monster_def_lv1", "wall           ", "monster_spd_lv1", "monster_spd_lv1", "hp_herb    "],
		["fragment_red   ", "monster_def_lv1", "fragment_yellow", "wall", "spirit_stone   ", "monster_def_lv1  ", "hp_herb        ", "wall           ", "hp_herb        ", "monster_spd_lv1", "boot_level1"],
	]


	stairs_config = {
		Vector2i(10, 5): {
			"target_scene": "res://scenes/maps/floor_1.gd",
			# "spawn_grid": Vector2i(5, 0)
		},
		Vector2i(0, 10): {
			"target_scene": "res://scenes/maps/floor_3.gd",
			# "spawn_grid": Vector2i(8, 10)
		},
	}
	
	items_config = {
		Vector2i(4, 2): 10
	}