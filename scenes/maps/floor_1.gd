# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["", "", "wall", "", "", "", "", "", ""],
		["", "eye", "wall", "", "wall", "wall", "wall", "wall", ""],
		["", "", "", "", "wall", "iron_sword", "", "wall", ""],
		["wall", "wall", "wall", "", "wall", "wall", "", "wall", ""],
		["", "", "", "", "", "", "", "wall", ""],
		["", "wall", "wall", "wall", "wall", "wall", "wall", "wall", ""],
		["", "wall", "", "", "", "", "", "", ""],
		["", "wall", "", "eye", "", "", "hp_potion", "", ""],
		["", "", "", "", "", "", "", "", "stairs"] # 连通2楼的楼梯
	]
	
	stairs_config = {
		Vector2i(8, 8): {
			"target_scene": "res://scenes/maps/floor_2.gd",
			"spawn_grid": Vector2i(8, 8) # 双向镜像：传送到2楼的 (8, 8)
		}
	}