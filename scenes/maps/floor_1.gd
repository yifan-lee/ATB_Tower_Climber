# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "", "", "tree_branch", "", "", "wall", "wall", "wall"],
		["wall", "wall", "", "", "wall", "wall", "wall", "", "", "wall", "wall"],
		["wall", "wall", "", "wall", "wall", "pedal_switch", "wall", "wall", "", "wall", "wall"],
		["wall", "wall", "", "", "", "bloodshot_eye", "", "", "", "wall", "wall"],
		["wall", "wall", "", "wall", "wall", "", "wall", "wall", "", "wall", "wall"],
		["wall", "wall", "", "", "wall", "", "wall", "", "", "wall", "wall"],
		["wall", "wall", "wall", "", "", "bloodshot_eye", "", "", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "", "wall", "wall", "wall", "wall", "wall"],
		["wall", "wall", "wall", "wall", "wall", "", "wall", "wall", "wall", "wall", "wall"],
	]
	
	stairs_config = {
		Vector2i(5, 0): {
			"target_scene": "res://scenes/maps/floor_2.gd",
			"spawn_grid": Vector2i(5, 0) # 传送到2楼的 (5, 0)
		}
	}

	triggers_config = {
		Vector2i(5, 4): [ # 用中括号 [] 包裹起来，变成一个数组（Array）
			{
				"target_grid": Vector2i(5, 0),
				"target_new_type": "stair_up"
			},
			{
				"target_grid": Vector2i(5, 10), # 注意：您的地图大小是 11x11，所以最大坐标是 10。如果您写 11 就会越界哦！
				"target_new_type": "wall"
			}
		]
	}