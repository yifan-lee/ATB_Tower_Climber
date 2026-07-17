# res://scenes/main.gd
extends Node

const MapFloor1 = preload("res://scenes/maps/floor_1.gd")
const Player = preload("res://entities/player.gd")
const BattleScene = preload("res://scenes/battle.gd")
const InventoryView = preload("res://ui/inventory_view.gd")
const LevelUpView = preload("res://ui/level_up_view.gd")
const StatInfoView = preload("res://ui/stat_info_view.gd")
const SkillMenuView = preload("res://ui/skill_menu_view.gd")
const SystemMessageView = preload("res://ui/system_message_view.gd")
const InfoPanel = preload("res://ui/info_panel.gd")

var game_container: Control
var ui_container: Control

var current_battle: Node = null
var current_map: Node2D
var player_instance: CharacterBody2D

var overlay_layer1: Control
var overlay_layer2: Control

var inventory_view: Control
var level_up_view: Control
var stat_info_view: Control
var skill_menu_view: Control
var system_message_view: Control
var info_panel: Control

var initial_player_position_x: int = 5
var initial_player_position_y: int = 10

enum AppState {MAP, BATTLE, INVENTORY, LEVEL_UP}
var current_state: AppState = AppState.MAP

func _ready():
	game_container = Control.new()
	game_container.name = "GameContainer"
	add_child(game_container)
	
	ui_container = Control.new()
	ui_container.name = "UIContainer"
	add_child(ui_container)

	var overlay_canvas = CanvasLayer.new()
	overlay_canvas.layer = 100
	add_child(overlay_canvas)
	
	overlay_layer1 = Control.new()
	overlay_layer1.name = "OverlayLayer1"
	overlay_canvas.add_child(overlay_layer1)
	
	overlay_layer2 = Control.new()
	overlay_layer2.name = "OverlayLayer2"
	overlay_canvas.add_child(overlay_layer2)
	
	var notification_canvas = CanvasLayer.new()
	notification_canvas.layer = 200
	add_child(notification_canvas)
	
	system_message_view = SystemMessageView.new()
	notification_canvas.add_child(system_message_view)

	EventBus.request_map_change.connect(_on_map_change_requested)
	EventBus.encounter_monster.connect(_on_encounter_monster)
	EventBus.battle_ended.connect(_on_battle_ended)

	_setup_containers()
	_load_initial_scenes()
	change_state(AppState.MAP)

func _setup_containers():
	game_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	game_container.position = Vector2(0, 0)
	
	ui_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.UI_AREA_HEIGHT)
	ui_container.position = Vector2(0, GameConfig.GAME_AREA_HEIGHT)
	
	overlay_layer1.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	overlay_layer1.position = Vector2(0, 0)
	
	overlay_layer2.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.UI_AREA_HEIGHT)
	overlay_layer2.position = Vector2(0, GameConfig.GAME_AREA_HEIGHT)
	
	system_message_view.set_anchors_preset(Control.PRESET_TOP_WIDE)
	system_message_view.size = Vector2(GameConfig.SCREEN_WIDTH, 0)

var loaded_maps: Dictionary = {}
var current_enemy_node: Node = null

func _load_initial_scenes():
	# 1. 加载地图 1 楼
	var initial_map_path = "res://scenes/maps/floor_1.gd"
	current_map = MapFloor1.new()
	game_container.add_child(current_map)
	loaded_maps[initial_map_path] = current_map
	
	# 2. 独立加载玩家角色
	player_instance = Player.new()
	player_instance.position = GameConfig.get_game_area_pixel_position(
		initial_player_position_x, initial_player_position_y
	)
	game_container.add_child(player_instance)
	
	# 3. 常驻加载各个 UI 视图到覆盖层
	stat_info_view = StatInfoView.new()
	stat_info_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer1.add_child(stat_info_view)
	
	level_up_view = LevelUpView.new()
	level_up_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	level_up_view.level_up_completed.connect(_on_level_up_completed)
	overlay_layer1.add_child(level_up_view)
	
	skill_menu_view = SkillMenuView.new()
	skill_menu_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer2.add_child(skill_menu_view)
	
	inventory_view = InventoryView.new()
	inventory_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer2.add_child(inventory_view)
	
	# 4. 加载 InfoPanel 到底部的 ui_container
	info_panel = InfoPanel.new()
	info_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_container.add_child(info_panel)
	
	_update_floor_info()

func _update_floor_info():
	if info_panel and current_map:
		info_panel.refresh_floor_info(current_map)
		info_panel.refresh_player_stats()

func change_state(new_state: AppState):
	# 1. 重置所有显示状态
	overlay_layer1.hide()
	overlay_layer2.hide()
	stat_info_view.hide()
	skill_menu_view.hide()
	inventory_view.hide()
	level_up_view.hide()
	info_panel.hide()
	
	if current_battle:
		current_battle.hide()
		
	_pause_map_and_player()
	current_state = new_state
	
	# 2. 根据新状态分配组件
	match new_state:
		AppState.MAP:
			_resume_map_and_player()
			info_panel.show()
		AppState.BATTLE:
			overlay_layer1.show()
			overlay_layer2.show()
			if current_battle:
				current_battle.show()
			skill_menu_view.show()
		AppState.INVENTORY:
			overlay_layer1.show()
			overlay_layer2.show()
			stat_info_view.show()
			inventory_view.show()
			inventory_view.refresh()
		AppState.LEVEL_UP:
			overlay_layer1.show()
			level_up_view.show()
			level_up_view.refresh()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			if current_state == AppState.MAP:
				change_state(AppState.INVENTORY)
		elif event.keycode == KEY_C or event.keycode == KEY_ESCAPE:
			if current_state == AppState.INVENTORY:
				inventory_view.clear()
				change_state(AppState.MAP)

func _pause_map_and_player():
	if current_map:
		current_map.process_mode = Node.PROCESS_MODE_DISABLED
	if player_instance:
		player_instance.process_mode = Node.PROCESS_MODE_DISABLED

func _resume_map_and_player():
	if current_map:
		current_map.process_mode = Node.PROCESS_MODE_INHERIT
	if player_instance:
		player_instance.process_mode = Node.PROCESS_MODE_INHERIT

func _on_map_change_requested(target_scene_path: String, spawn_grid_pos: Vector2i):
	if current_map != null:
		_set_map_active(current_map, false)
		
	if loaded_maps.has(target_scene_path):
		current_map = loaded_maps[target_scene_path]
		_set_map_active(current_map, true)
	else:
		var NewMapClass = load(target_scene_path)
		current_map = NewMapClass.new()
		loaded_maps[target_scene_path] = current_map
		_set_map_active(current_map, true)
	
	player_instance.position = GameConfig.get_game_area_pixel_position(spawn_grid_pos.x, spawn_grid_pos.y)
	_update_floor_info()

# 封装一个极简的函数，代替原来的 hide() / show()
# 为什么不用 hide()？因为在 Godot 中，hide() 只能隐藏贴图，**无法禁用静态墙壁(TileMap)的物理碰撞**！
func _set_map_active(map_node: Node2D, active: bool):
	if active:
		if map_node.get_parent() == null:
			game_container.add_child(map_node)
		map_node.show()
		map_node.process_mode = Node.PROCESS_MODE_INHERIT
		# 确保玩家显示在地图上层（地图加入后，玩家应在其之上）
		if player_instance and player_instance.get_parent() == game_container:
			game_container.move_child(player_instance, -1)
	else:
		if map_node.get_parent() != null:
			game_container.remove_child(map_node) # 彻底拔除物理隐形墙！
		map_node.hide()
		map_node.process_mode = Node.PROCESS_MODE_DISABLED


# 进入战斗
func _on_encounter_monster(monster_id: String, monster_node: Node = null):
	current_enemy_node = monster_node
	
	current_battle = BattleScene.new()
	current_battle.setup(monster_id)
	current_battle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer1.add_child(current_battle)
	
	change_state(AppState.BATTLE)

# 退出战斗
func _on_battle_ended(result: String = ""):
	if current_battle:
		current_battle.queue_free()
		current_battle = null
		
	if result == "win" and current_enemy_node != null:
		if current_map and current_map.has_method("remove_entity_by_node"):
			current_map.remove_entity_by_node(current_enemy_node)
		else:
			current_enemy_node.queue_free()
	current_enemy_node = null
		
	var player_stats = EntityDB.get_stats("player")
	if player_stats.stat_points > 0:
		change_state(AppState.LEVEL_UP)
	else:
		change_state(AppState.MAP)

func _on_level_up_completed():
	change_state(AppState.MAP)