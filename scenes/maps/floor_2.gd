# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["wall", "wall", "wall", "wall", "wall", "stair_down", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "", "wall", "wall", "wall", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "", "wall", "wall", "wall", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "bloodshot", "wall", "wall", "wall", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "red_cap", "wall", "wall", "wall", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "stone_troll", "", "", "", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "", "wall", "wall"],
        ["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "stair_up", "wall", "wall"],
	]


	stairs_config = {
		Vector2i(5, 0): {
			"target_scene": "res://scenes/maps/floor_1.gd",
			"spawn_grid": Vector2i(5, 0)
		},
        Vector2i(8, 10): {
			"target_scene": "res://scenes/maps/floor_3.gd",
			"spawn_grid": Vector2i(8, 10)
		},
	}