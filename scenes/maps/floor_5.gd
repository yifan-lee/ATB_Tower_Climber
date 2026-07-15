# res://scenes/maps/floor_5.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	map_data = [
		["stairs", "", "", "", "", "", "", "", ""], # (0, 0) 楼梯回4楼
		["", "iron_sword", "", "", "", "", "", "iron_helm", ""],
		["", "", "", "", "", "", "", "", ""],
		["", "", "", "wall", "wall", "wall", "", "", ""],
		["", "", "", "wall", "bloodshot_eye", "wall", "", "", ""], # 殿堂中央的大眼Boss
		["", "", "", "wall", "wall", "wall", "", "", ""],
		["", "", "", "", "", "", "", "", ""],
		["", "swift_boots", "", "", "", "", "", "hp_potion", ""],
		["", "", "", "", "stairs", "", "", "", ""] # (4, 8) 通关楼梯（可以触发胜利结局或循环）
	]
	
	stairs_config = {
		Vector2i(0, 0): {
			"target_scene": "res://scenes/maps/floor_4.gd",
			"spawn_grid": Vector2i(0, 0)
		},
		Vector2i(4, 8): {
			# 踩中此楼梯通关游戏，回到 1 楼起点
			"target_scene": "res://scenes/maps/floor_1.gd",
			"spawn_grid": Vector2i(0, 0)
		}
	}