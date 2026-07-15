# res://scenes/maps/floor_4.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["stairs", "", "", "", "wall", "", "", "", "stairs"],
		# (0, 0) 去5楼 | (8, 0) 回3楼
		["wall", "wall", "wall", "", "wall", "", "wall", "wall", ""],
		["hp_potion", "", "wall", "", "", "", "bloodshot_eye", "wall", ""],
		["wall", "", "wall", "wall", "wall", "wall", "", "wall", ""],
		["", "", "", "", "bloodshot_eye", "wall", "", "", ""],
		["", "wall", "wall", "wall", "", "wall", "wall", "wall", "wall"],
		["", "wall", "hp_potion", "wall", "", "", "", "", ""],
		["", "wall", "", "wall", "wall", "wall", "wall", "wall", ""],
		["", "", "", "", "", "", "", "", ""]
	]
	
	stairs_config = {
		Vector2i(8, 0): {
			"target_scene": "res://scenes/maps/floor_3.gd",
			"spawn_grid": Vector2i(8, 0)
		},
		Vector2i(0, 0): {
			"target_scene": "res://scenes/maps/floor_5.gd",
			"spawn_grid": Vector2i(0, 0) # 传送到5楼的 (0, 0)
		}
	}