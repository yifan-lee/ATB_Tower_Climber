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
			"triggers_config": map_node.triggers_config.duplicate(true),
			"fake_walls_config": map_node.fake_walls_config.duplicate(true) if "fake_walls_config" in map_node else {}
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
	
	# 2. Skip Debug Hook (Removed)
	
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
		var MapClass = load(map_path)
		var map_node = MapClass.new()
		
		# Override its data with saved data
		var map_saved = maps_state[map_path]
		map_node.map_data = map_saved["map_data"].duplicate(true)
		map_node.stairs_config = _restore_vector2i_keys(map_saved["stairs_config"].duplicate(true))
		map_node.triggers_config = _restore_vector2i_keys(map_saved["triggers_config"].duplicate(true))
		map_node.fake_walls_config = _restore_vector2i_keys(map_saved.get("fake_walls_config", {}).duplicate(true))
		
		main_scene.loaded_maps[map_path] = map_node
		
	# 4. Jump to loaded map
	var grid_pos = GameConfig.get_grid_position(Vector2(state["player_pos_x"], state["player_pos_y"]))
	main_scene._on_map_change_requested(current_map_path, grid_pos)
	
	EventBus.show_system_message.emit(["GAME LOADED: " + save_name])
	
	# 5. Tell UI components to refresh their `player_stats` references
	EventBus.game_loaded.emit()

static func delete_game(save_name: String) -> bool:
	_ensure_dir()
	var state_path = SAVE_DIR + save_name + ".json"
	var stats_path = SAVE_DIR + save_name + "_stats.tres"
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		var deleted_any = false
		if dir.file_exists(save_name + ".json"):
			dir.remove(save_name + ".json")
			deleted_any = true
		if dir.file_exists(save_name + "_stats.tres"):
			dir.remove(save_name + "_stats.tres")
			deleted_any = true
		if deleted_any:
			EventBus.show_system_message.emit(["SAVE DELETED: " + save_name])
			return true
	return false

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

static func _restore_vector2i_keys(dict: Dictionary) -> Dictionary:
	var new_dict = {}
	for k in dict.keys():
		var new_k = k
		if typeof(k) == TYPE_STRING and k.begins_with("(") and k.ends_with(")"):
			# Parse strings like "(10, 5)" back into Vector2i
			var parts = k.substr(1, k.length() - 2).split(",")
			if parts.size() == 2:
				new_k = Vector2i(parts[0].to_int(), parts[1].to_int())
		new_dict[new_k] = dict[k]
	return new_dict
