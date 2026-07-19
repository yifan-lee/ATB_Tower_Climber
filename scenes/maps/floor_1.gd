# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	floor_name_key = "MAP_FLOOR_1_NAME"
	floor_desc_key = "MAP_FLOOR_1_DESC"
	
	map_data = [
		["wall", "wall", "wall", "wall", "wall", "wall         ", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "             ", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "    ", "    ", "tree_branch  ", "    ", "    ", "wall", "wall", "wall"],
		["wall", "wall", "    ", "    ", "wall", "wall         ", "wall", "    ", "    ", "wall", "wall"],
		["wall", "wall", "    ", "wall", "wall", "pedal_switch ", "wall", "wall", "    ", "wall", "wall"],
		["wall", "wall", "    ", "    ", "    ", "monster_first", "    ", "    ", "    ", "wall", "wall"],
		["wall", "wall", "    ", "wall", "wall", "             ", "wall", "wall", "    ", "wall", "wall"],
		["wall", "wall", "    ", "    ", "wall", "             ", "wall", "    ", "    ", "wall", "wall"],
		["wall", "wall", "wall", "    ", "    ", "monster_first", "    ", "    ", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "             ", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "             ", "wall", "wall", "wall", "wall", "wall"],
	]
	
	stairs_config = {
		Vector2i(5, 0): {
			"target_scene": "res://scenes/maps/floor_2.gd",
			"spawn_grid": Vector2i(5, 0) # 传送到2楼的 (5, 0)
		}
	}

	triggers_config = {
		Vector2i(5, 4): [
			{
				"type": "change_tile",
				"target_grid": Vector2i(5, 0),
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
				"amount": 50,
				"one_shot": true
			}
		]
	}