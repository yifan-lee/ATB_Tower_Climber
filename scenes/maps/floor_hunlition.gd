# res://scenes/maps/floor_5.gd
extends "res://scenes/maps/base_map.gd"

func _init():
	config = {"floor": 5, "name": "MAP_FLOOR_UNKNOWN", "desc": "MAP_DESC_UNKNOWN"}
	
	# 这里定义“真实”的迷宫地形
	# 除了真正的"wall"，其他所有非墙壁元素（floor, monster, stair_up, item）
	# 在初始化时都会被自动转换成"假墙"！
	var real_map_data = [
		["        ", "wall", "wall        ", "wall ", "wall ", "stair_up  ", "wall ", "wall        ", "wall ", "wall ", "wall    "],
		["        ", "wall", "wall        ", "floor", "floor", "floor     ", "floor", "floor       ", "wall ", "floor", "wall    "],
		["        ", "wall", "wall        ", "wall ", "wall ", "wall      ", "wall ", "wall        ", "wall ", "floor", "wall    "],
		["        ", "wall", "spirit_stone", "wall ", "floor", "floor     ", "floor", "spirit_stone", "wall ", "floor", "wall    "],
		["        ", "wall", "wall        ", "wall ", "floor", "wall      ", "floor", "wall        ", "wall ", "floor", "wall    "],
		["        ", "wall", "floor       ", "floor", "floor", "wall      ", "floor", "floor       ", "floor", "floor", "wall    "],
		["        ", "wall", "wall        ", "wall ", "wall ", "wall      ", "wall ", "wall        ", "wall ", "wall ", "wall    "],
		["        ", "wall", "wall        ", "floor", "floor", "floor     ", "floor", "floor       ", "floor", "floor", "wall    "],
		["        ", "    ", "            ", "     ", "     ", "          ", "     ", "            ", "     ", "     ", "wall    "],
		["        ", "    ", "wall        ", "floor", "wall ", "floor     ", "wall ", "floor       ", "wall ", "     ", "        "],
		["stair_up", "wall", "wall        ", "wall ", "wall ", "stair_down", "wall ", "wall        ", "wall ", "wall ", "stair_up"],
	]
	
	# 楼梯配置
	stairs_config = {
		# Vector2i(0, 10): {
		# 	"target_scene": "res://scenes/maps/floor_4.gd",
		# },
		# Vector2i(10, 10): {
		# 	"target_scene": "res://scenes/maps/floor_6.gd", # 假设有第6层
		# }
	}
	
	# 初始化 map_data 满屏都是墙
	map_data = []
	for y in range(GameConfig.GRID_ROWS):
		var row = []
		for x in range(GameConfig.GRID_COLUMNS):
			row.append("wall")
		map_data.append(row)
		
	# 根据 real_map_data 提取出假墙配置
	fake_walls_config = {}
	for y in range(GameConfig.GRID_ROWS):
		for x in range(GameConfig.GRID_COLUMNS):
			var real_tile = str(real_map_data[y][x]).strip_edges()
			if real_tile == "" or real_tile == "0":
				real_tile = "floor"
			
			if real_tile != "wall":
				# 注入假墙配置，系统会自动将视觉替换成假墙，玩家撞击时再还原成 real_tile
				fake_walls_config[Vector2i(x, y)] = real_tile
