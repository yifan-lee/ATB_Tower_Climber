# res://scenes/main.gd
extends Node

const MapFloor1 = preload("res://scenes/maps/floor_1.gd")
const InfoPanel = preload("res://ui/info_panel.gd")
const Player = preload("res://entities/player.gd")
const BattleScene = preload("res://scenes/battle.gd")
const InventoryView = preload("res://ui/inventory_view.gd")
const LevelUpView = preload("res://ui/level_up_view.gd")


var game_container: Control
var ui_container: Control

var current_battle: Node = null
var current_map: Node2D
var player_instance: CharacterBody2D
var inventory_view: Control
var level_up_view: Control

var initial_player_position_x: int = 0
var initial_player_position_y: int = 0

var overlay_layer: CanvasLayer

func _ready():
	game_container = Control.new()
	game_container.name = "GameContainer"
	add_child(game_container)
	
	ui_container = Control.new()
	ui_container.name = "UIContainer"
	add_child(ui_container)

	overlay_layer = CanvasLayer.new()
	overlay_layer.name = "OverlayLayer"
	overlay_layer.layer = 100 # Ensure it's always on top
	add_child(overlay_layer)

	EventBus.request_map_change.connect(_on_map_change_requested)
	EventBus.encounter_monster.connect(_on_encounter_monster)
	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.show_level_up.connect(_on_level_up_shown)
	EventBus.hide_level_up.connect(_on_level_up_hidden)

	_setup_containers()
	_load_initial_scenes()

	
func _setup_containers():
	# 动态设置 GameContainer 尺寸
	game_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	game_container.position = Vector2(0, 0)
	
	# 动态设置 UIContainer 尺寸和位置
	ui_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.UI_AREA_HEIGHT)
	ui_container.position = Vector2(0, GameConfig.GAME_AREA_HEIGHT)

var loaded_maps: Dictionary = {}
var current_enemy_node: Node = null

func _load_initial_scenes():
	# 1. 加载下方 UI
	var info_panel = InfoPanel.new()
	ui_container.add_child(info_panel)
	
	# 2. 加载地图 1 楼
	var initial_map_path = "res://scenes/maps/floor_1.gd"
	current_map = MapFloor1.new()
	game_container.add_child(current_map)
	loaded_maps[initial_map_path] = current_map
	
	# 3. 独立加载玩家角色
	player_instance = Player.new()
	player_instance.position = GameConfig.get_game_area_pixel_position(
		initial_player_position_x, initial_player_position_y
	)
	game_container.add_child(player_instance)
	
	# 4. 加载背包层 (挂载到 CanvasLayer，保证永远在最上层！)
	inventory_view = InventoryView.new()
	inventory_view.set_anchors_preset(Control.PRESET_TOP_LEFT)
	inventory_view.position = Vector2(0, 0)
	inventory_view.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	overlay_layer.add_child(inventory_view)
	
	# 5. 加载升级层 (挂载到 CanvasLayer，保证永远在最上层！)
	level_up_view = LevelUpView.new()
	level_up_view.set_anchors_preset(Control.PRESET_TOP_LEFT)
	level_up_view.position = Vector2(0, 0)
	level_up_view.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	overlay_layer.add_child(level_up_view)

enum AppState {MAP, BATTLE, INVENTORY}
var current_state: AppState = AppState.MAP

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			if current_state == AppState.MAP:
				current_state = AppState.INVENTORY
				_pause_map_and_player()
				EventBus.show_inventory.emit()
		elif event.keycode == KEY_C or event.keycode == KEY_ESCAPE:
			if current_state == AppState.INVENTORY:
				current_state = AppState.MAP
				_resume_map_and_player()
				EventBus.hide_inventory.emit()

func _pause_map_and_player():
	if current_map:
		current_map.process_mode = Node.PROCESS_MODE_DISABLED
	if player_instance:
		player_instance.process_mode = Node.PROCESS_MODE_DISABLED
		# player_instance.hide()

func _resume_map_and_player():
	if current_map:
		# current_map.show()
		current_map.process_mode = Node.PROCESS_MODE_INHERIT
	if player_instance:
		# player_instance.show()
		player_instance.process_mode = Node.PROCESS_MODE_INHERIT

func _on_map_change_requested(target_scene_path: String, spawn_grid_pos: Vector2i):
	# 1. 挂起旧地图（为了解决隐形墙Bug，这里必须从树上拔除碰撞体）
	if current_map != null:
		_set_map_active(current_map, false)
		
	# 2. 从缓存加载新地图，如果没有则实例化
	if loaded_maps.has(target_scene_path):
		current_map = loaded_maps[target_scene_path]
		_set_map_active(current_map, true)
	else:
		var NewMapClass = load(target_scene_path)
		current_map = NewMapClass.new()
		loaded_maps[target_scene_path] = current_map
		_set_map_active(current_map, true)
	
	# 3. 将玩家精准传送到新地图的指定网格位置
	player_instance.position = GameConfig.get_game_area_pixel_position(spawn_grid_pos.x, spawn_grid_pos.y)

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
	current_state = AppState.BATTLE
	current_enemy_node = monster_node
	
	# 1. 暂停并隐藏探索地图和玩家
	_pause_map_and_player()
		
	# 2. 实例化并加载战斗场景
	current_battle = BattleScene.new()
	current_battle.setup(monster_id) # 注入遭遇的怪物ID
	overlay_layer.add_child(current_battle)


# 退出战斗
func _on_battle_ended(result: String = ""):
	current_state = AppState.MAP
	# 1. 销毁战斗场景
	if current_battle:
		current_battle.queue_free()
		current_battle = null
		
	# 2. 如果战斗胜利，则直接销毁缓存地图里的怪物节点
	if result == "win" and current_enemy_node != null:
		current_enemy_node.queue_free()
	current_enemy_node = null
		
	# 3. 恢复并显示探索地图和玩家 (完美保留在原位！)
	_resume_map_and_player()

	var player_stats = EntityDB.get_stats("player")
	if player_stats.stat_points > 0:
		EventBus.show_level_up.emit()


func _on_level_up_shown():
	current_state = AppState.INVENTORY # Reuse inventory state to block map input
	_pause_map_and_player()

func _on_level_up_hidden():
	current_state = AppState.MAP
	_resume_map_and_player()