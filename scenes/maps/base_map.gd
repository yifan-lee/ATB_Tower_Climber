# res://scenes/maps/base_map.gd
extends Node2D

var map_data = []
var stairs_config = {}
var triggers_config = {}
var items_config = {}
var fake_walls_config = {}
var doors_config = {}
var statues_config = {}
var entities_size_config = {}
var custom_state = {}

var config: Dictionary = {"floor": 0, "name": "MAP_FLOOR_UNKNOWN", "desc": "MAP_DESC_UNKNOWN"}

var trigger_handlers = {
	"change_tile": Callable(self, "_handle_change_tile"),
	"give_exp": Callable(self, "_handle_give_exp")
}

var visual_grid: Array = []
var entities_data: Dictionary = {}

var pending_interaction_door_pos: Vector2i = Vector2i(-1, -1)

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
				var v = str(map_data[y][x]).strip_edges()
				if v == "" or v == "0":
					cell_val = "floor"
				elif v in ["wall", "door_closed", "door_opened", "stair_up", "stair_down", "portal_closed", "portal_open", "pedal_switch", "pedal_trap"]:
					cell_val = v
				elif EntityDB.db.has(v):
					var e_type = "shop" if v == "shop" else "enemy"
					_spawn_entity(v, Vector2i(x, y), e_type)
					cell_val = "floor"
				elif ItemDB.db.has(v):
					_spawn_entity(v, Vector2i(x, y), "item")
					cell_val = "floor"
				else:
					cell_val = "floor"
			
			if y < map_data.size():
				map_data[y][x] = cell_val
				
			sprite.texture = MapDB.get_texture(cell_val)
			if sprite.texture:
				var orig_size = sprite.texture.get_size()
				sprite.scale = Vector2(GameConfig.GRID_SIZE / orig_size.x, GameConfig.GRID_SIZE / orig_size.y)


func _calculate_entity_pixel_pos(grid_pos: Vector2i, size: Vector2i) -> Vector2:
	var center_x = grid_pos.x + (size.x - 1) / 2.0
	var center_y = grid_pos.y + (size.y - 1) / 2.0
	return Vector2(
		center_x * GameConfig.GRID_SIZE + (GameConfig.GRID_SIZE / 2.0) + GameConfig.WALL_THICKNESS,
		center_y * GameConfig.GRID_SIZE + (GameConfig.GRID_SIZE / 2.0) + GameConfig.WALL_THICKNESS
	)

func _register_entity(id: String, entity_type: String, node: Node, grid_pos: Vector2i, size: Vector2i):
	var entity_info = {
		"id": id,
		"type": entity_type,
		"node": node,
		"pos": grid_pos,
		"size": size
	}
	for dx in range(size.x):
		for dy in range(size.y):
			entities_data[grid_pos + Vector2i(dx, dy)] = entity_info

func _spawn_entity(id: String, grid_pos: Vector2i, entity_type: String):
	var size = entities_size_config.get(grid_pos, Vector2i(1, 1))
	var pixel_pos = _calculate_entity_pixel_pos(grid_pos, size)
	
	var node
	var z_layer
	
	if entity_type == "shop":
		node = BaseShop.new()
		z_layer = GameConfig.ZLayer.SHOP
	elif entity_type == "item":
		node = BaseItem.new()
		z_layer = GameConfig.ZLayer.ITEM
	else:
		node = BaseEnemy.new()
		z_layer = GameConfig.ZLayer.ENEMY
		
	node.setup(id)
	node.scale = Vector2(size.x, size.y)
	node.position = pixel_pos
	node.z_index = z_layer
	add_child(node)
	
	_register_entity(id, entity_type, node, grid_pos, size)

func get_cell_interaction(grid_pos: Vector2i) -> Dictionary:
	if grid_pos.x < 0 or grid_pos.x >= GameConfig.GRID_COLUMNS or grid_pos.y < 0 or grid_pos.y >= GameConfig.GRID_ROWS:
		return {"type": "wall"}
		
	var entity = get_entity_at(grid_pos)
	if not entity.is_empty():
		if entity.get("type", "") == "enemy":
			return {"type": "enemy", "id": entity["id"], "node": entity["node"], "pos": entity["pos"]}
		elif entity.get("type", "") == "shop":
			return {"type": "door", "pos": entity["pos"]}
		# Items are generally passable, handled during step
			
	if fake_walls_config.has(grid_pos):
		return {"type": "fake_wall"}
		
	var terrain = str(map_data[grid_pos.y][grid_pos.x])
	if terrain in ["wall", "portal_closed", "", "0"]:
		return {"type": "wall"}
		
	if terrain == "door_closed":
		return {"type": "door", "pos": grid_pos}
		
	return {"type": "passable"}

func trigger_interaction(grid_pos: Vector2i):
	var entity = get_entity_at(grid_pos)
	if not entity.is_empty() and entity.get("type", "") == "shop":
		var player_stats = EntityDB.get_stats("player")
		var current_red = player_stats.inventory.get("fragment_red", 0)
		var current_blue = player_stats.inventory.get("fragment_blue", 0)
		var current_yellow = player_stats.inventory.get("fragment_yellow", 0)
		
		var cost_red = GameRules.STATUE_EXCHANGE_COST_RED
		var cost_blue = GameRules.STATUE_EXCHANGE_COST_BLUE
		var cost_yellow = GameRules.STATUE_EXCHANGE_COST_YELLOW
		
		var title = "一座古老的商店，似乎蕴含着神秘的力量..."
		var options = [
			{
				"text": "消耗 %d 红色碎片，提升 %d 攻击力 (拥有: %d)" % [cost_red, GameRules.STATUE_EXCHANGE_GAIN_ATK, current_red],
				"action": "shop_exchange_atk",
				"enabled": current_red >= cost_red,
				"close_on_select": false,
				"metadata": {"pos": grid_pos, "cost": cost_red, "gain": GameRules.STATUE_EXCHANGE_GAIN_ATK, "expected_change": {"atk": GameRules.STATUE_EXCHANGE_GAIN_ATK, "fragment_red": - cost_red}}
			},
			{
				"text": "消耗 %d 蓝色碎片，提升 %d 速度 (拥有: %d)" % [cost_blue, GameRules.STATUE_EXCHANGE_GAIN_SPD, current_blue],
				"action": "shop_exchange_spd",
				"enabled": current_blue >= cost_blue,
				"close_on_select": false,
				"metadata": {"pos": grid_pos, "cost": cost_blue, "gain": GameRules.STATUE_EXCHANGE_GAIN_SPD, "expected_change": {"spd": GameRules.STATUE_EXCHANGE_GAIN_SPD, "fragment_blue": - cost_blue}}
			},
			{
				"text": "消耗 %d 黄色碎片，提升 %d 防御力 (拥有: %d)" % [cost_yellow, GameRules.STATUE_EXCHANGE_GAIN_DEF, current_yellow],
				"action": "shop_exchange_def",
				"enabled": current_yellow >= cost_yellow,
				"close_on_select": false,
				"metadata": {"pos": grid_pos, "cost": cost_yellow, "gain": GameRules.STATUE_EXCHANGE_GAIN_DEF, "expected_change": {"def": GameRules.STATUE_EXCHANGE_GAIN_DEF, "fragment_yellow": - cost_yellow}}
			},
			{
				"text": "离开",
				"action": "shop_leave",
				"enabled": true,
				"metadata": {}
			}
		]
		EventBus.show_interaction_dialog.emit(title, options)
		return

	var terrain = str(map_data[grid_pos.y][grid_pos.x])
	if terrain == "door_closed":
		var config = doors_config.get(grid_pos, {})
		var cost = config.get("cost", 0)
		var monster_id = config.get("monster", "")
		
		var m_name = monster_id
		var m_stats = EntityDB.get_stats(monster_id)
		if m_stats:
			m_name = m_stats.entity_name
			
		var player_stats = EntityDB.get_stats("player")
		var current_stones = player_stats.inventory.get("spirit_stone", 0)
		var pay_enabled = current_stones >= cost
		
		var title = "一扇门挡住了去路。打开它需要花费 " + str(cost) + " 颗灵石。"
		var options = [
			{
				"text": "交出 " + str(cost) + " 颗灵石",
				"action": "door_pay",
				"enabled": pay_enabled,
				"metadata": {"pos": grid_pos, "cost": cost}
			},
			{
				"text": "与 " + m_name + " 战斗",
				"action": "door_fight",
				"enabled": true,
				"metadata": {"pos": grid_pos, "monster": monster_id}
			},
			{
				"text": "离开",
				"action": "door_cancel",
				"enabled": true,
				"metadata": {}
			}
		]
		EventBus.show_interaction_dialog.emit(title, options)


func open_door(grid_pos: Vector2i, show_message: bool = true):
	var current = str(map_data[grid_pos.y][grid_pos.x])
	if current == "door_closed":
		map_data[grid_pos.y][grid_pos.x] = "door_opened"
		change_tile(grid_pos, "door_opened")
		if show_message:
			EventBus.show_system_message.emit(["MSG_DOOR_OPENED"])

func reveal_fake_wall(grid_pos: Vector2i, show_message: bool = true):
	if not fake_walls_config.has(grid_pos):
		return
		
	var real_type = fake_walls_config[grid_pos]
	fake_walls_config.erase(grid_pos)
	
	if real_type in ["floor", "stair_up", "stair_down", "portal_open", "portal_closed", "door_closed", "door_opened"]:
		change_tile(grid_pos, real_type)
	else:
		change_tile(grid_pos, "floor")
		if ItemDB.db.has(real_type):
			_spawn_entity(real_type, grid_pos, "item")
		elif EntityDB.db.has(real_type):
			var e_type = "shop" if real_type == "shop" else "enemy"
			_spawn_entity(real_type, grid_pos, e_type)
			
	if show_message:
		EventBus.show_system_message.emit(["MSG_FAKE_WALL_REVEALED"])

	
func get_entity_at(grid_pos: Vector2i) -> Dictionary:
	if entities_data.has(grid_pos):
		return entities_data[grid_pos]
	return {}

func remove_entity(grid_pos: Vector2i):
	if entities_data.has(grid_pos):
		var data = entities_data[grid_pos]
		if is_instance_valid(data["node"]):
			data["node"].queue_free()
		
		var root_pos = data["pos"]
		var size = data.get("size", Vector2i(1, 1))
		for dx in range(size.x):
			for dy in range(size.y):
				entities_data.erase(root_pos + Vector2i(dx, dy))

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
	if not EventBus.interaction_action_selected.is_connected(_on_interaction_action_selected):
		EventBus.interaction_action_selected.connect(_on_interaction_action_selected)
	if not EventBus.battle_ended.is_connected(_on_battle_ended):
		EventBus.battle_ended.connect(_on_battle_ended)

func _exit_tree():
	if EventBus.player_stepped.is_connected(_on_player_stepped):
		EventBus.player_stepped.disconnect(_on_player_stepped)
	if EventBus.interaction_action_selected.is_connected(_on_interaction_action_selected):
		EventBus.interaction_action_selected.disconnect(_on_interaction_action_selected)
	if EventBus.battle_ended.is_connected(_on_battle_ended):
		EventBus.battle_ended.disconnect(_on_battle_ended)
		
func on_player_entered(grid_pos: Vector2i):
	pass

func _on_interaction_action_selected(action: String, metadata: Dictionary):
	# Make sure this interaction belongs to the currently active map
	if self.get_parent() == null or not self.visible:
		return
		
	if action == "door_pay":
		var player_stats = EntityDB.get_stats("player")
		player_stats.inventory["spirit_stone"] -= metadata.get("cost", 0)
		open_door(metadata.pos)
	elif action == "door_fight":
		pending_interaction_door_pos = metadata.pos
		EventBus.encounter_monster.emit(metadata.monster, null)
	elif action == "shop_exchange_atk":
		var player_stats = EntityDB.get_stats("player")
		player_stats.inventory["fragment_red"] = player_stats.inventory.get("fragment_red", 0) - metadata.get("cost", 1)
		player_stats.atk += metadata.get("gain", 0)
		EventBus.show_system_message.emit(["提升了 %d 攻击力！" % metadata.get("gain", 0)])
		trigger_interaction(metadata.pos)
	elif action == "shop_exchange_spd":
		var player_stats = EntityDB.get_stats("player")
		player_stats.inventory["fragment_blue"] = player_stats.inventory.get("fragment_blue", 0) - metadata.get("cost", 1)
		player_stats.spd += metadata.get("gain", 0)
		EventBus.show_system_message.emit(["提升了 %d 速度！" % metadata.get("gain", 0)])
		trigger_interaction(metadata.pos)
	elif action == "shop_exchange_def":
		var player_stats = EntityDB.get_stats("player")
		player_stats.inventory["fragment_yellow"] = player_stats.inventory.get("fragment_yellow", 0) - metadata.get("cost", 1)
		player_stats.def += metadata.get("gain", 0)
		EventBus.show_system_message.emit(["提升了 %d 防御力！" % metadata.get("gain", 0)])
		trigger_interaction(metadata.pos)

func _on_battle_ended(result: String):
	if self.get_parent() == null or not self.visible:
		return
		
	if result == "win" and pending_interaction_door_pos != Vector2i(-1, -1):
		open_door(pending_interaction_door_pos)
	pending_interaction_door_pos = Vector2i(-1, -1)

func _on_player_stepped(grid_pos: Vector2i):
	var terrain = str(map_data[grid_pos.y][grid_pos.x])
	
	# Check teleport
	if terrain in ["stair_up", "stair_down", "portal_open"]:
		if stairs_config.has(grid_pos):
			var config = stairs_config[grid_pos]
			var target_spawn = config.get("spawn_grid", grid_pos)
			EventBus.request_map_change.emit(config["target_scene"], target_spawn)
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
	if not entity.is_empty() and entity.get("type", "") == "item":
		var item_id = entity["id"]
		var item_data = ItemDB.get_item(item_id)
		
		var amount = 1
		if items_config.has(grid_pos):
			var cfg = items_config[grid_pos]
			if typeof(cfg) == TYPE_DICTIONARY:
				amount = cfg.get("amount", 1)
			elif typeof(cfg) == TYPE_INT or typeof(cfg) == TYPE_FLOAT:
				amount = int(cfg)
		
		var stats = EntityDB.get_stats("player")
		if stats.inventory.has(item_id):
			stats.inventory[item_id] += amount
		else:
			stats.inventory[item_id] = amount
			
		EventBus.show_system_message.emit(["MSG_GOT_ITEM", item_data.item_name, " x" + str(amount)])
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
