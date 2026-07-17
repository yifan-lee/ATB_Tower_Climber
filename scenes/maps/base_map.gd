# res://scenes/maps/base_map.gd
extends Node2D

var map_data = []
var stairs_config = {}
var triggers_config = {}

var floor_name_key: String = "MAP_FLOOR_UNKNOWN"
var floor_desc_key: String = "MAP_DESC_UNKNOWN"

var trigger_handlers = {
	"change_tile": Callable(self, "_handle_change_tile"),
	"give_exp": Callable(self, "_handle_give_exp")
}

var visual_grid: Array = []
var entities_data: Dictionary = {}

const BaseEnemy = preload("res://entities/enemy/base_enemy.gd")

func _ready():
	var floor_bg = ColorRect.new()
	floor_bg.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	floor_bg.color = ThemeConfig.COLOR_MAP_BG
	add_child(floor_bg)

	_draw_aesthetic_boundaries()
	_build_map_grids()

func _draw_aesthetic_boundaries():
	var wall_thickness = GameConfig.WALL_THICKNESS
	var width = GameConfig.SCREEN_WIDTH
	var height = GameConfig.GAME_AREA_HEIGHT
	var wall_color = ThemeConfig.COLOR_MAP_WALL
	
	_add_border_rect(Vector2(width / 2.0, wall_thickness / 2.0), Vector2(width, wall_thickness), wall_color)
	_add_border_rect(Vector2(width / 2.0, height - wall_thickness / 2.0), Vector2(width, wall_thickness), wall_color)
	_add_border_rect(Vector2(wall_thickness / 2.0, height / 2.0), Vector2(wall_thickness, height), wall_color)
	_add_border_rect(Vector2(width - wall_thickness / 2.0, height / 2.0), Vector2(wall_thickness, height), wall_color)

func _add_border_rect(pos: Vector2, size: Vector2, color: Color):
	var visual = ColorRect.new()
	visual.size = size
	visual.color = color
	visual.position = pos - size / 2.0
	add_child(visual)

func _build_map_grids():
	visual_grid.resize(GameConfig.GRID_ROWS)
	for y in range(GameConfig.GRID_ROWS):
		visual_grid[y] = []
		visual_grid[y].resize(GameConfig.GRID_COLUMNS)
		for x in range(GameConfig.GRID_COLUMNS):
			var sprite = Sprite2D.new()
			sprite.position = GameConfig.get_game_area_pixel_position(x, y)
			add_child(sprite)
			visual_grid[y][x] = sprite
			
			var cell_val = "floor"
			if y < map_data.size() and x < map_data[y].size():
				var v = str(map_data[y][x])
				if v == "" or v == "0":
					cell_val = "floor"
				elif v in ["wall", "door_closed", "door_open", "stair_up", "stair_down", "portal_closed", "portal_open", "pedal_switch", "pedal_trap"]:
					cell_val = v
				elif EntityDB.db.has(v):
					cell_val = "floor"
					_spawn_entity(v, Vector2i(x, y), true)
				elif ItemDB.db.has(v):
					cell_val = "floor"
					_spawn_entity(v, Vector2i(x, y), false)
				else:
					cell_val = "floor"
			
			if y < map_data.size():
				map_data[y][x] = cell_val
				
			sprite.texture = MapDB.get_texture(cell_val)
			if sprite.texture:
				var orig_size = sprite.texture.get_size()
				sprite.scale = Vector2(GameConfig.GRID_SIZE / orig_size.x, GameConfig.GRID_SIZE / orig_size.y)

func _spawn_entity(id: String, grid_pos: Vector2i, is_enemy: bool):
	var pixel_pos = GameConfig.get_game_area_pixel_position(grid_pos.x, grid_pos.y)
	var node = null
	
	if is_enemy:
		var enemy = BaseEnemy.new()
		enemy.setup(id)
		enemy.position = pixel_pos
		add_child(enemy)
		node = enemy
	else:
		var item_data = ItemDB.get_item(id)
		var sprite = Sprite2D.new()
		if item_data.icon:
			sprite.texture = item_data.icon
		else:
			sprite.texture = MapDB.get_fallback_texture() # 使用占位符防止隐形
			
		var orig_size = sprite.texture.get_size()
		sprite.scale = Vector2(GameConfig.GRID_SIZE / orig_size.x, GameConfig.GRID_SIZE / orig_size.y)
		sprite.position = pixel_pos
		add_child(sprite)
		node = sprite
		
	entities_data[grid_pos] = {
		"id": id,
		"is_enemy": is_enemy,
		"node": node
	}

func is_passable(grid_pos: Vector2i) -> bool:
	if grid_pos.x < 0 or grid_pos.x >= GameConfig.GRID_COLUMNS or grid_pos.y < 0 or grid_pos.y >= GameConfig.GRID_ROWS:
		return false
		
	var terrain = str(map_data[grid_pos.y][grid_pos.x])
	if terrain in ["wall", "door_closed", "portal_closed", "", "0"]:
		return false
		
	return true
	
func get_entity_at(grid_pos: Vector2i) -> Dictionary:
	if entities_data.has(grid_pos):
		return entities_data[grid_pos]
	return {}

func remove_entity(grid_pos: Vector2i):
	if entities_data.has(grid_pos):
		var data = entities_data[grid_pos]
		if is_instance_valid(data["node"]):
			data["node"].queue_free()
		entities_data.erase(grid_pos)

func remove_entity_by_node(node: Node):
	var to_remove = null
	for grid_pos in entities_data:
		if entities_data[grid_pos]["node"] == node:
			to_remove = grid_pos
			break
	if to_remove != null:
		remove_entity(to_remove)

func change_tile(grid_pos: Vector2i, new_type: String):
	if grid_pos.y >= 0 and grid_pos.y < GameConfig.GRID_ROWS and grid_pos.x >= 0 and grid_pos.x < GameConfig.GRID_COLUMNS:
		map_data[grid_pos.y][grid_pos.x] = new_type
		var sprite = visual_grid[grid_pos.y][grid_pos.x]
		sprite.texture = MapDB.get_texture(new_type)
		if sprite.texture:
			var orig_size = sprite.texture.get_size()
			sprite.scale = Vector2(GameConfig.GRID_SIZE / orig_size.x, GameConfig.GRID_SIZE / orig_size.y)

func _enter_tree():
	if not EventBus.player_stepped.is_connected(_on_player_stepped):
		EventBus.player_stepped.connect(_on_player_stepped)

func _exit_tree():
	if EventBus.player_stepped.is_connected(_on_player_stepped):
		EventBus.player_stepped.disconnect(_on_player_stepped)
		
func _on_player_stepped(grid_pos: Vector2i):
	var terrain = str(map_data[grid_pos.y][grid_pos.x])
	
	# Check teleport
	if terrain in ["stair_up", "stair_down", "portal_open"]:
		if stairs_config.has(grid_pos):
			var config = stairs_config[grid_pos]
			EventBus.request_map_change.emit(config["target_scene"], config["spawn_grid"])
			return
			
	# Check triggers
	if triggers_config.has(grid_pos):
		var trigger_data = triggers_config[grid_pos]
		# Support both a single dict and an array of dicts for multiple changes
		if typeof(trigger_data) == TYPE_DICTIONARY:
			trigger_data = [trigger_data]
			
		var remaining_actions = []
		for action in trigger_data:
			var action_type = action.get("type", "")
			
			# 兼容旧格式（如果没有显式定义 type）
			if action_type == "":
				if action.has("target_grid"):
					action_type = "change_tile"
				elif action.has("give_exp"):
					action_type = "give_exp"
					action["amount"] = action["give_exp"]
					
			if trigger_handlers.has(action_type):
				trigger_handlers[action_type].call(action)
			else:
				push_warning("未知的触发器动作类型: " + action_type)
					
			if not action.get("one_shot", false):
				remaining_actions.append(action)
				
		if remaining_actions.is_empty():
			triggers_config.erase(grid_pos)
		else:
			triggers_config[grid_pos] = remaining_actions
			
	# Check items
	var entity = get_entity_at(grid_pos)
	if not entity.is_empty() and not entity["is_enemy"]:
		var item_id = entity["id"]
		var item_data = ItemDB.get_item(item_id)
		
		var stats = EntityDB.get_stats("player")
		if stats.inventory.has(item_id):
			stats.inventory[item_id] += 1
		else:
			stats.inventory[item_id] = 1
			
		EventBus.show_system_message.emit(["MSG_GOT_ITEM", item_data.item_name])
		remove_entity(grid_pos)

# ==================== Trigger Handlers ====================
func _handle_change_tile(action: Dictionary):
	var target_pos = action.get("target_grid", Vector2i(-1, -1))
	var new_type = action.get("target_new_type", "floor")
	if target_pos != Vector2i(-1, -1):
		change_tile(target_pos, new_type)

func _handle_give_exp(action: Dictionary):
	var amount = action.get("amount", 0)
	if amount > 0:
		var player_stats = EntityDB.get_stats("player")
		var leveled_up = player_stats.gain_exp(amount)
		EventBus.player_stats_changed.emit()
		EventBus.show_system_message.emit(["MSG_GAIN_EXP_PREFIX", str(amount), "MSG_GAIN_EXP_SUFFIX"])
		if leveled_up:
			EventBus.show_level_up.emit()
