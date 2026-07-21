# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	floor_name_key = "MAP_FLOOR_2_NAME"
	floor_desc_key = "MAP_FLOOR_2_DESC"
	
	map_data = [
		["        ", "    ", "    ", "wall", "    ", "    ", "    ", "wall", "hp_herb", "monster_spd_lv1    ", "boot_level1"],
		["        ", "    ", "    ", "    ", "    ", "    ", "    ", "wall", "monster_spd_lv1    ", "    ", "monster_spd_lv1          "],
		["        ", "    ", "    ", "wall", "    ", "    ", "    ", "wall", "wall", "monster_spd_lv1    ", "wall      "],
		["wall    ", "wall", "wall", "wall", "wall", "    ", "wall", "wall", "wall", "    ", "wall      "],
		["        ", "    ", "    ", "    ", "wall", "    ", "    ", "    ", "    ", "    ", "wall      "],
		["        ", "wall", "wall", "wall", "wall", "    ", "wall", "wall", "wall", "    ", "stair_down"],
		["        ", "    ", "    ", "    ", "    ", "    ", "wall", "wall", "wall", "wall", "wall      "],
		["        ", "    ", "wall", "wall", "wall", "wall", "wall", "    ", "    ", "    ", "          "],
		["        ", "    ", "wall", "    ", "    ", "    ", "    ", "    ", "    ", "    ", "          "],
		["        ", "    ", "wall", "    ", "    ", "    ", "wall", "    ", "    ", "    ", "          "],
		["stair_up", "    ", "wall", "    ", "    ", "    ", "wall", "    ", "    ", "    ", "          "],
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