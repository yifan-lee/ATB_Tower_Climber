extends SceneTree
func _init():
	var save_manager = load("res://core/save_manager.gd").new()
	var sys_view = load("res://ui/system_menu_view.gd").new()
	var player_menu = load("res://ui/player_menu_view.gd").new()
	var stat_info = load("res://ui/stat_info_view.gd").new()
	var level_up = load("res://ui/level_up_view.gd").new()
	var battle_menu = load("res://ui/battle_menu_view.gd").new()
	var info_panel = load("res://ui/info_panel.gd").new()
	print("All classes loaded successfully without syntax errors.")
	quit()
