# res://scenes/maps/floor_3.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["", "", "", "", "wall", "", "", "", "stairs"], # (8, 0) 去4楼
		["", "wall", "wall", "", "wall", "", "wall", "wall", "wall"],
		["iron_helm", "wall", "", "", "", "", "", "", ""],
		["", "wall", "", "wall", "wall", "wall", "wall", "", "wall"],
		["", "", "", "", "bloodshot_eye", "wall", "", "", ""],
		["wall", "wall", "", "wall", "wall", "wall", "wall", "", "wall"],
		["hp_potion", "", "", "", "", "", "", "", ""],
		["", "wall", "", "wall", "wall", "", "wall", "wall", "wall"],
		["stairs", "", "", "", "wall", "", "", "", ""]
		# (0, 8) 楼梯回2楼
	]
	
	stairs_config = {
		Vector2i(0, 8): {
			"target_scene": "res://scenes/maps/floor_2.gd",
			"spawn_grid": Vector2i(0, 8)
		},
		Vector2i(8, 0): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(8, 0) # 传送到4楼的 (8, 0)
		}
	}