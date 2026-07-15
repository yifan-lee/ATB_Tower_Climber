# res://scenes/maps/floor_2.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["", "", "", "", "wall", "swift_boots", "", "", ""],
		["wall", "wall", "wall", "", "", "", "wall", "wall", "wall"],
		["", "", "wall", "", "", "", "", "", ""],
		["", "", "wall", "wall", "wall", "wall", "wall", "bloodshot_eye", "wall"],
		["", "", "", "", "", "", "wall", "", "wall"],
		["wall", "wall", "wall", "wall", "wall", "", "wall", "", "wall"],
		["", "", "bloodshot_eye", "", "wall", "", "", "", ""],
		["", "", "wall", "", "wall", "wall", "wall", "", ""],
		["stairs", "", "wall", "", "", "", "", "", "stairs"]
		# (8, 8) 楼梯回1楼 | (0, 8) 楼梯去3楼
	]
	
	stairs_config = {
		Vector2i(8, 8): {
			"target_scene": "res://scenes/maps/floor_1.gd",
			"spawn_grid": Vector2i(8, 8)
		},
		Vector2i(0, 8): {
			"target_scene": "res://scenes/maps/floor_3.gd",
			"spawn_grid": Vector2i(0, 8) # 传送到3楼的 (0, 8)
		}
	}