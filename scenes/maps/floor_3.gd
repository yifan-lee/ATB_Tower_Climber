# res://scenes/maps/floor_1.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["", "", "", "", "", "", "", "", "", "", ""],
		["", "wall", "", "wall", "", "wall", "", "wall", "wall", "wall", ""],
        ["", "wall", "", "", "", "", "", "", "", "", ""],
        ["", "wall", "", "wall", "", "wall", "wall", "wall", "", "wall", ""],
        ["", "wall", "", "wall", "", "", "", "", "", "wall", ""],
        ["", "", "", "", "", "", "", "wall", "", "wall", ""],
        ["wall", "wall", "", "wall", "", "wall", "wall", "wall", "", "wall", ""],
        ["wall", "wall", "", "", "", "", "", "", "", "wall", ""],
        ["wall", "wall", "", "wall", "wall", "wall", "", "wall", "", "wall", ""],
        ["wall", "wall", "", "", "", "", "", "", "", "", ""],
        ["wall", "wall", "stair_up", "wall", "wall", "wall", "wall", "wall", "stair_down", "wall", "wall"],
	]


	stairs_config = {
		Vector2i(8, 10): {
			"target_scene": "res://scenes/maps/floor_2.gd",
			"spawn_grid": Vector2i(8, 10)
		},
        Vector2i(2, 10): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(2, 10)
		},
	}

var last_direction: Vector2i = Vector2i.ZERO

func check_custom_move_rules(current_pos: Vector2i, target_pos: Vector2i, direction: Vector2i) -> bool:
	if last_direction != Vector2i.ZERO:
		var relative_left = Vector2i(last_direction.y, -last_direction.x)
		var backward = -last_direction
		
		if direction == relative_left or direction == backward:
			EventBus.show_system_message.emit("MSG_RULES_VIOLATED")
			var player = get_tree().get_nodes_in_group("player")[0]
			player.position = GameConfig.get_game_area_pixel_position(8, 10)
			last_direction = Vector2i.ZERO
			return false
			
	last_direction = direction
	return true

	# triggers_config = {
	# 	Vector2i(5, 4): [ # 用中括号 [] 包裹起来，变成一个数组（Array）
	# 		{
	# 			"target_grid": Vector2i(5, 0),
	# 			"target_new_type": "stair_up"
	# 		},
	# 		{
	# 			"target_grid": Vector2i(5, 10), # 注意：您的地图大小是 11x11，所以最大坐标是 10。如果您写 11 就会越界哦！
	# 			"target_new_type": "wall"
	# 		}
	# 	]
	# }