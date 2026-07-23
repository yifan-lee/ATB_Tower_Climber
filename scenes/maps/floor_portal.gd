# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["portal_open", "    ", "portal_open", "wall", "portal_open", "stair_up  ", "portal_open", "wall", "portal_open", "    ", "portal_open"],
		["           ", "    ", "           ", "wall", "           ", "          ", "           ", "wall", "           ", "    ", "           "],
		["           ", "    ", "           ", "wall", "           ", "          ", "           ", "wall", "           ", "    ", "           "],
		["wall       ", "wall", "wall       ", "wall", "wall       ", "wall      ", "wall       ", "wall", "wall       ", "wall", "wall       "],
		["portal_open", "    ", "portal_open", "wall", "portal_open", "          ", "portal_open", "wall", "portal_open", "    ", "portal_open"],
		["           ", "    ", "           ", "wall", "           ", "          ", "           ", "wall", "           ", "    ", "           "],
		["           ", "    ", "           ", "wall", "           ", "          ", "           ", "wall", "           ", "    ", "           "],
		["wall       ", "wall", "wall       ", "wall", "wall       ", "wall      ", "wall       ", "wall", "wall       ", "wall", "wall       "],
		["portal_open", "    ", "portal_open", "wall", "portal_open", "          ", "portal_open", "wall", "portal_open", "    ", "portal_open"],
		["           ", "    ", "           ", "wall", "           ", "          ", "           ", "wall", "           ", "    ", "           "],
		["           ", "    ", "           ", "wall", "           ", "stair_down", "           ", "wall", "           ", "    ", "           "],
	]


	stairs_config = {
		Vector2i(5, 10): {
			"target_scene": "res://scenes/maps/floor_3.gd",
		},
		Vector2i(5, 0): {
			"target_scene": "res://scenes/maps/floor_5.gd", # 修正为 floor_5.gd (假设上楼是到 5 楼)
		},
		Vector2i(0, 8): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(1, 2)
		},
		Vector2i(2, 8): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(1, 6)
		},
		Vector2i(4, 8): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(1, 2)
		},
		Vector2i(6, 8): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(9, 2)
		},
		Vector2i(8, 8): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(5, 2)
		},
		Vector2i(10, 8): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(1, 10)
		},
		Vector2i(0, 4): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(9, 10)
		},
		Vector2i(2, 4): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(9, 10)
		},
		Vector2i(4, 4): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(1, 10)
		},
		Vector2i(6, 4): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(5, 6)
		},
		Vector2i(8, 4): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(1, 2)
		},
		Vector2i(10, 4): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(9, 2)
		},
		Vector2i(0, 0): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(9, 2)
		},
		Vector2i(2, 0): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(9, 6)
		},
		Vector2i(4, 0): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(1, 10)
		},
		Vector2i(6, 0): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(9, 10)
		},
		Vector2i(8, 0): { # true
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(5, 6)
		},
		Vector2i(10, 0): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(5, 6)
		},
	}
