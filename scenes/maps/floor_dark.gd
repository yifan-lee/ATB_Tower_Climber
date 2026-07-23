# res://scenes/maps/floor_6.gd
extends "res://scenes/maps/base_map.gd"

var last_revealed_tiles = []

func _init():
	config = {"floor": -1, "name": "MAP_FLOOR_UNKNOWN", "desc": "MAP_DESC_UNKNOWN"}
	
	map_data = [
		["wall", "wall ", "wall ", "wall ", "wall ", "stair_up       ", "wall ", "wall ", "wall ", "wall ", "wall"],
		["wall", "floor", "floor", "floor", "floor", "floor          ", "floor", "floor", "floor", "floor", "wall"],
		["wall", "floor", "wall ", "wall ", "wall ", "wall           ", "wall ", "wall ", "wall ", "floor", "wall"],
		["wall", "floor", "wall ", "floor", "floor", "floor          ", "floor", "floor", "wall ", "floor", "wall"],
		["wall", "floor", "wall ", "floor", "wall ", "wall           ", "wall ", "floor", "wall ", "floor", "wall"],
		["wall", "floor", "floor", "floor", "wall ", "monster_def_lv1", "wall ", "floor", "floor", "floor", "wall"],
		["wall", "floor", "wall ", "floor", "wall ", "wall           ", "wall ", "floor", "wall ", "floor", "wall"],
		["wall", "floor", "wall ", "floor", "floor", "floor          ", "floor", "floor", "wall ", "floor", "wall"],
		["wall", "floor", "wall ", "wall ", "wall ", "wall           ", "wall ", "wall ", "wall ", "floor", "wall"],
		["wall", "floor", "floor", "floor", "floor", "floor          ", "floor", "floor", "floor", "floor", "wall"],
		["wall", "wall ", "wall ", "wall ", "wall ", "stair_down     ", "wall ", "wall ", "wall ", "wall ", "wall"],
	]
	
	stairs_config = {
		Vector2i(5, 10): {
			"target_scene": "res://scenes/maps/floor_5.gd",
			"spawn_grid": Vector2i(10, 10)
		},
		Vector2i(5, 0): {
			"target_scene": "res://scenes/maps/floor_7.gd", # 假设有第7层
		}
	}

func _ready():
	super._ready()
	# Initial hide: everything should be hidden
	# However, _build_map_grids is called in base_map's _ready, so we must hide them here (or override).
	# Because _build_map_grids creates the sprites, they are valid after super._ready() or implicit _ready.
	for y in range(GameConfig.GRID_ROWS):
		for x in range(GameConfig.GRID_COLUMNS):
			_set_cell_visible(Vector2i(x, y), false)
			
	# Watch for steps
	EventBus.player_stepped.connect(_on_player_moved_update_visibility)

func _exit_tree():
	# Optional: disconnect from EventBus, though base_map already handles some.
	if EventBus.player_stepped.is_connected(_on_player_moved_update_visibility):
		EventBus.player_stepped.disconnect(_on_player_moved_update_visibility)

func on_player_entered(spawn_grid_pos: Vector2i):
	update_visibility(spawn_grid_pos)

func _on_player_moved_update_visibility(grid_pos: Vector2i):
	update_visibility(grid_pos)

func update_visibility(center_pos: Vector2i):
	# Hide previous
	for pos in last_revealed_tiles:
		_set_cell_visible(pos, false)
	last_revealed_tiles.clear()
	
	# Compute new tiles to reveal
	var to_reveal = [
		center_pos,
		center_pos + Vector2i.UP,
		center_pos + Vector2i.DOWN,
		center_pos + Vector2i.LEFT,
		center_pos + Vector2i.RIGHT
	]
	
	for pos in to_reveal:
		if pos.x >= 0 and pos.x < GameConfig.GRID_COLUMNS and pos.y >= 0 and pos.y < GameConfig.GRID_ROWS:
			_set_cell_visible(pos, true)
			last_revealed_tiles.append(pos)

func _set_cell_visible(grid_pos: Vector2i, is_visible: bool):
	if grid_pos.y < 0 or grid_pos.y >= GameConfig.GRID_ROWS or grid_pos.x < 0 or grid_pos.x >= GameConfig.GRID_COLUMNS:
		return
		
	# visual_grid from base_map
	var sprite = visual_grid[grid_pos.y][grid_pos.x]
	if is_instance_valid(sprite):
		sprite.visible = is_visible
		
	var entity = get_entity_at(grid_pos)
	if not entity.is_empty():
		var node = entity["node"]
		if is_instance_valid(node):
			node.visible = is_visible
