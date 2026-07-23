# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	config = {"floor": 1, "name": "MAP_FLOOR_NAME_ATK", "desc": "MAP_FLOOR_DESC_ATK"}
	
	map_data = [
		["wall", "wall         ", "wall", "wall", "wall", "sword_lv5    ", "wall", "wall", "wall", "wall         ", "wall"],
		["wall", "wall         ", "    ", "    ", "    ", "             ", "    ", "    ", "    ", "wall         ", "wall"],
		["wall", "wall         ", "    ", "    ", "    ", "             ", "    ", "    ", "    ", "wall         ", "wall"],
		["wall", "wall         ", "    ", "    ", "    ", "             ", "    ", "    ", "    ", "wall         ", "wall"],
		["wall", "wall         ", "    ", "    ", "    ", "             ", "    ", "    ", "    ", "wall         ", "wall"],
		["wall", "pedal_switch ", "wall", "wall", "wall", "             ", "wall", "wall", "wall", "tree_branch  ", "wall"],
		["wall", "monster_first", "    ", "    ", "wall", "wall         ", "wall", "    ", "    ", "monster_first", "wall"],
		["wall", "wall         ", "wall", "    ", "wall", "             ", "wall", "    ", "wall", "wall         ", "wall"],
		["wall", "wall         ", "wall", "    ", "    ", "monster_first", "    ", "    ", "wall", "wall         ", "wall"],
		["wall", "wall         ", "wall", "wall", "wall", "             ", "wall", "wall", "wall", "wall         ", "wall"],
		["wall", "wall         ", "wall", "wall", "wall", "             ", "wall", "wall", "wall", "wall         ", "wall"],
	]
	

	stairs_config = {
		Vector2i(10, 5): {
			"target_scene": "res://scenes/maps/floor_2.gd",
			# "spawn_grid": Vector2i(10, 5)
		}
	}

	triggers_config = {
		Vector2i(1, 5): [
			{
				"type": "change_tile",
				"target_grid": Vector2i(10, 5),
				"target_new_type": "stair_up",
				"one_shot": true
			},
			{
				"type": "change_tile",
				"target_grid": Vector2i(5, 10),
				"target_new_type": "wall",
				"one_shot": true
			},
			{
				"type": "give_exp",
				"amount": 10,
				"one_shot": true
			}
		]
	}