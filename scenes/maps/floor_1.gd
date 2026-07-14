# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init():
	# 这是 2 楼的地图设计，中间多了一堵墙
	map_data = [
		["", "", "eye", "iron_sword", "stairs"],
		["", "", "", "", "wall"],
		["", "wall", "", "wall", "wall"],
		["", "", "", "wall", "wall"],
		["wall", "wall", "", "wall", "wall"]
	]

	stairs_config = {
		Vector2i(4, 0): {
			"target_scene": "res://scenes/maps/floor_2.gd", # 去2楼
			"spawn_grid": Vector2i(4, 0)
		}
	}