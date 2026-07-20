# res://core/debug_system.gd
extends CanvasLayer

const SAVE_DIR = "user://breakpoints/"

static var pending_load_data: Dictionary = {}

var ui_container: PanelContainer
var action_label: Label
var input_line: LineEdit
var item_list: ItemList
var confirm_btn: Button
var cancel_btn: Button

enum Mode {NONE, SAVE, LOAD}
var current_mode: Mode = Mode.NONE

func _ready():
	layer = 1000 # Always on top
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	ui_container = PanelContainer.new()
	ui_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	ui_container.custom_minimum_size = Vector2(400, 300)
	ui_container.hide()
	add_child(ui_container)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.8, 0.8, 0.2)
	ui_container.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_container.add_child(vbox)
	
	action_label = Label.new()
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.add_theme_color_override("font_color", Color(1, 1, 0))
	vbox.add_child(action_label)
	
	input_line = LineEdit.new()
	input_line.placeholder_text = "Enter breakpoint name..."
	vbox.add_child(input_line)
	
	item_list = ItemList.new()
	item_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(item_list)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	confirm_btn = Button.new()
	confirm_btn.text = "Confirm"
	confirm_btn.pressed.connect(_on_confirm)
	hbox.add_child(confirm_btn)
	
	cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_on_cancel)
	hbox.add_child(cancel_btn)
	
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("breakpoints"):
		dir.make_dir("breakpoints")
		
	if not pending_load_data.is_empty():
		call_deferred("_inject_load_data")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_open_save_ui()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F6:
			_open_load_ui()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and current_mode != Mode.NONE:
			_on_cancel()
			get_viewport().set_input_as_handled()

func _open_save_ui():
	current_mode = Mode.SAVE
	action_label.text = "SAVE BREAKPOINT"
	input_line.show()
	item_list.hide()
	
	var date_time = Time.get_datetime_string_from_system().replace("T", "_").replace(":", "-")
	input_line.text = "bp_" + date_time
	
	ui_container.show()
	input_line.grab_focus()
	get_tree().paused = true

func _open_load_ui():
	current_mode = Mode.LOAD
	action_label.text = "LOAD BREAKPOINT"
	input_line.hide()
	item_list.show()
	item_list.clear()
	
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var saves = []
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				saves.append(file_name.replace(".json", ""))
			file_name = dir.get_next()
		
		saves.sort()
		saves.reverse() # Newest first
		for s in saves:
			item_list.add_item(s)
			
	if item_list.item_count > 0:
		item_list.select(0)
		
	ui_container.show()
	item_list.grab_focus()
	get_tree().paused = true

func _on_cancel():
	ui_container.hide()
	current_mode = Mode.NONE
	get_tree().paused = false

func _on_confirm():
	if current_mode == Mode.SAVE:
		var bp_name = input_line.text.strip_edges()
		if bp_name == "":
			return
		_execute_save(bp_name)
		
	elif current_mode == Mode.LOAD:
		var selected = item_list.get_selected_items()
		if selected.is_empty():
			return
		var bp_name = item_list.get_item_text(selected[0])
		_execute_load(bp_name)
		
	_on_cancel()

func _execute_save(bp_name: String):
	var main_scene = get_parent()
	if not main_scene or not "current_map" in main_scene:
		EventBus.show_system_message.emit(["DEBUG: Can only save from main scene!"])
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
		
	var state_path = SAVE_DIR + bp_name + ".json"
	var stats_path = SAVE_DIR + bp_name + "_stats.tres"
	
	var file = FileAccess.open(state_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state, "\t"))
		
	var stats = EntityDB.get_stats("player")
	ResourceSaver.save(stats.duplicate(true), stats_path)
	
	EventBus.show_system_message.emit(["DEBUG: Breakpoint [" + bp_name + "] saved!"])

func _execute_load(bp_name: String):
	var state_path = SAVE_DIR + bp_name + ".json"
	var stats_path = SAVE_DIR + bp_name + "_stats.tres"
	
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
		
	# Store to global static variable and restart scene!
	pending_load_data = {
		"bp_name": bp_name,
		"state": state,
		"stats": saved_stats
	}
	
	# Restart the scene to purge ALL states, clear UI references, etc.
	get_tree().reload_current_scene()

func _inject_load_data():
	var data = pending_load_data
	pending_load_data = {} # Clear it immediately
	
	var main_scene = get_parent()
	if not main_scene or not "current_map" in main_scene:
		return
		
	# 1. Inject Stats globally
	EntityDB.db["player"] = data["stats"].duplicate(true)
	
	# 2. Inject Maps
	var state = data["state"]
	var maps_state = state.get("maps_state", {})
	var current_map_path = state.get("current_map_path", "")
	
	# Clear the initially loaded maps in main (Floor 1)
	for p in main_scene.loaded_maps.keys():
		main_scene.loaded_maps[p].queue_free()
	main_scene.loaded_maps.clear()
	main_scene.current_map = null
	
	# Reconstruct all maps EXCEPT the current one (which we force-fresh-load)
	for map_path in maps_state.keys():
		if map_path == current_map_path:
			continue # Skip current map, we want it fresh!
			
		var MapClass = load(map_path)
		var map_node = MapClass.new()
		
		# Override its data
		var map_saved = maps_state[map_path]
		map_node.map_data = map_saved["map_data"].duplicate(true)
		map_node.stairs_config = map_saved["stairs_config"].duplicate(true)
		map_node.triggers_config = map_saved["triggers_config"].duplicate(true)
		
		main_scene.loaded_maps[map_path] = map_node
		
	# 3. Load the current map (this will naturally parse from script because it's not in loaded_maps yet)
	var grid_pos = GameConfig.get_grid_position(Vector2(state["player_pos_x"], state["player_pos_y"]))
	main_scene._on_map_change_requested(current_map_path, grid_pos)
	
	EventBus.show_system_message.emit(["DEBUG: Breakpoint [" + data["bp_name"] + "] loaded completely!"])
