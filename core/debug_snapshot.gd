# res://core/debug_snapshot.gd
extends RefCounted
class_name DebugSnapshot

const STATS_PATH = "user://debug_stats.tres"
const STATE_PATH = "user://debug_state.json"

static func save_state(map_node: Node2D, player: CharacterBody2D):
	if map_node == null or player == null:
		return
		
	# Save Player Stats (duplicate so modifying current stats doesn't affect save)
	var stats = EntityDB.get_stats("player")
	var err = ResourceSaver.save(stats.duplicate(true), STATS_PATH)
	if err != OK:
		push_error("Failed to save debug stats")
		
	# Save Map & Position
	var grid_pos = GameConfig.get_grid_position(player.position)
	var state = {
		"pos_x": grid_pos.x,
		"pos_y": grid_pos.y,
		"map_path": ""
	}
	
	# Try to get the original map script path
	var script = map_node.get_script()
	if script:
		state["map_path"] = script.resource_path
		
	var file = FileAccess.open(STATE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))
		EventBus.show_system_message.emit(["DEBUG: 断点已保存！按 F6 读取。"])

static func load_state(main_scene: Node):
	if not FileAccess.file_exists(STATS_PATH) or not FileAccess.file_exists(STATE_PATH):
		EventBus.show_system_message.emit(["DEBUG: 未找到任何保存的断点！"])
		return
		
	# Load Player Stats
	var saved_stats = ResourceLoader.load(STATS_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	if saved_stats:
		# Replace the global player stats with the loaded snapshot
		EntityDB.db["player"] = saved_stats.duplicate(true)
		
	# Load Map & Position
	var file = FileAccess.open(STATE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			var map_path = data.get("map_path", "")
			var pos_x = data.get("pos_x", 0)
			var pos_y = data.get("pos_y", 0)
			
			if map_path != "":
				# Call main scene's map change function to reload the map
				main_scene._on_map_change_requested(map_path, Vector2i(pos_x, pos_y))
				# Trigger UI updates to reflect loaded stats
				EventBus.player_stats_changed.emit()
				EventBus.show_system_message.emit(["DEBUG: 断点读取成功！"])
