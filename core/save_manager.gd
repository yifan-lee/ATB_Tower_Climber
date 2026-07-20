# res://core/save_manager.gd
extends Node
class_name SaveManager

const SAVE_DIR = "user://saves/"

static func _ensure_dir():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

static func save_game(save_name: String, main_scene: Node):
	_ensure_dir()
	
	if not "current_map" in main_scene or not main_scene.current_map:
		EventBus.show_system_message.emit(["MSG_SYS_ERROR", "Cannot save here."])
		return
		
	var state = {
		"player_pos_x": main_scene.player_instance.position.x,
		"player_pos_y": main_scene.player_instance.position.y,
		"current_map_path": "",
		"maps_state": {}
	}
	
	# Save maps state
	for map_path in main_scene.loaded_maps.keys():
		var map_node = main_scene.loaded_maps[map_path]
		if map_node == main_scene.current_map:
			state["current_map_path"] = map_path
			
		state["maps_state"][map_path] = {
			"map_data": map_node.map_data.duplicate(true),
			"stairs_config": map_node.stairs_config.duplicate(true),
			"triggers_config": map_node.triggers_config.duplicate(true)
		}
		
	var state_path = SAVE_DIR + save_name + ".json"
	var stats_path = SAVE_DIR + save_name + "_stats.tres"
	
	var file = FileAccess.open(state_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state, "\t"))
		
	var stats = EntityDB.get_stats("player")
	ResourceSaver.save(stats.duplicate(true), stats_path)
	
	EventBus.show_system_message.emit(["GAME SAVED: " + save_name])

static func load_game(save_name: String, main_scene: Node):
	_ensure_dir()
	var state_path = SAVE_DIR + save_name + ".json"
	var stats_path = SAVE_DIR + save_name + "_stats.tres"
	
	var file = FileAccess.open(state_path, FileAccess.READ)
	if not file:
		return
		
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return
		
	var state = json.get_data()
	var saved_stats = ResourceLoader.load(stats_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	if not saved_stats:
		return
		
	# 1. Update Global Player Stats
	EntityDB.db["player"] = saved_stats.duplicate(true)
	
	# 2. Check Debug Hook
	var is_debug = FileAccess.file_exists("res://core/debug_map_hook.gd")
	
	# 3. Restore Maps
	var maps_state = state.get("maps_state", {})
	var current_map_path = state.get("current_map_path", "")
	
	# Clear currently loaded maps
	for p in main_scene.loaded_maps.keys():
		main_scene.loaded_maps[p].queue_free()
	main_scene.loaded_maps.clear()
	main_scene.current_map = null
	
	# Rebuild maps
	for map_path in maps_state.keys():
		if is_debug and map_path == current_map_path:
			# Skip injecting saved map_data for the current map in debug mode,
			# forcing it to parse fresh data from its .gd script!
			continue
			
		var MapClass = load(map_path)
		var map_node = MapClass.new()
		
		# Override its data with saved data
		var map_saved = maps_state[map_path]
		map_node.map_data = map_saved["map_data"].duplicate(true)
		map_node.stairs_config = map_saved["stairs_config"].duplicate(true)
		map_node.triggers_config = map_saved["triggers_config"].duplicate(true)
		
		main_scene.loaded_maps[map_path] = map_node
		
	# 4. Jump to loaded map
	var grid_pos = GameConfig.get_grid_position(Vector2(state["player_pos_x"], state["player_pos_y"]))
	main_scene._on_map_change_requested(current_map_path, grid_pos)
	
	EventBus.show_system_message.emit(["GAME LOADED: " + save_name])
	
	# 5. Tell UI components to refresh their `player_stats` references
	EventBus.game_loaded.emit()

static func get_save_files() -> Array:
	_ensure_dir()
	var dir = DirAccess.open(SAVE_DIR)
	var saves = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				saves.append(file_name.replace(".json", ""))
			file_name = dir.get_next()
	saves.sort()
	saves.reverse()
	return saves
