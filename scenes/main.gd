# res://scenes/main.gd
extends Node

const MapFloor1 = preload("res://scenes/maps/floor_1.gd")
const InfoPanel = preload("res://ui/info_panel.gd")
const Player = preload("res://entities/player.gd") # 预加载玩家脚本
const BattleScene = preload("res://scenes/battle.gd")
var current_battle: Node = null

@onready var game_container = $GameContainer
@onready var ui_container = $UIContainer

var current_map: Node2D
var player_instance: CharacterBody2D

func _ready():
	_setup_containers()
	_load_initial_scenes()
	EventBus.request_map_change.connect(_on_map_change_requested)
	EventBus.encounter_monster.connect(_on_encounter_monster)
	EventBus.battle_ended.connect(_on_battle_ended)

func _setup_containers():
	# 动态设置 GameContainer 尺寸
	game_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.EXPLORE_AREA_HEIGHT)
	game_container.position = Vector2(0, 0)
	
	# 动态设置 UIContainer 尺寸和位置
	ui_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.INFO_AREA_HEIGHT)
	ui_container.position = Vector2(0, GameConfig.EXPLORE_AREA_HEIGHT)

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
	# 将玩家放置在屏幕中央 (基于 GameConfig 配置的尺寸)
	player_instance.position = Vector2(
		GameConfig.WALL_THICKNESS + GameConfig.GRID_SIZE * (GameConfig.GRID_COLUMNS + 1.0) / 2.0 - GameConfig.GRID_SIZE / 2.0,
		GameConfig.WALL_THICKNESS + GameConfig.GRID_SIZE * GameConfig.GRID_ROWS - GameConfig.GRID_SIZE / 2.0
	)
	
	# 将玩家也添加到 GameContainer，它与地图是分离的！
	game_container.add_child(player_instance)

func _on_map_change_requested(target_scene_path: String, spawn_grid_pos: Vector2i):
	# 1. 隐藏旧地图，不再销毁
	if current_map != null:
		current_map.hide()
		current_map.process_mode = Node.PROCESS_MODE_DISABLED
		
	# 2. 从缓存加载新地图，如果没有则实例化
	if loaded_maps.has(target_scene_path):
		current_map = loaded_maps[target_scene_path]
		current_map.show()
		current_map.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		var NewMapClass = load(target_scene_path)
		current_map = NewMapClass.new()
		game_container.add_child(current_map)
		loaded_maps[target_scene_path] = current_map
	
	# 3. 将玩家精准传送到新地图的指定网格位置
	player_instance.position = Vector2(
		GameConfig.WALL_THICKNESS + spawn_grid_pos.x * GameConfig.GRID_SIZE + (GameConfig.GRID_SIZE / 2.0),
		GameConfig.WALL_THICKNESS + spawn_grid_pos.y * GameConfig.GRID_SIZE + (GameConfig.GRID_SIZE / 2.0)
	)


# 进入战斗
func _on_encounter_monster(monster_id: String, monster_node: Node = null):
	current_enemy_node = monster_node
	
	# 1. 暂停并隐藏探索地图和玩家
	if current_map:
		current_map.hide()
		current_map.process_mode = Node.PROCESS_MODE_DISABLED
	if player_instance:
		player_instance.hide()
		player_instance.process_mode = Node.PROCESS_MODE_DISABLED
		
	# 2. 实例化并加载战斗场景
	current_battle = BattleScene.new()
	current_battle.setup(monster_id) # 注入遭遇的怪物ID
	game_container.add_child(current_battle)

# 退出战斗
func _on_battle_ended(result: String = ""):
	# 1. 销毁战斗场景
	if current_battle:
		current_battle.queue_free()
		current_battle = null
		
	# 2. 如果战斗胜利，则直接销毁缓存地图里的怪物节点
	if result == "win" and current_enemy_node != null:
		current_enemy_node.queue_free()
	current_enemy_node = null
		
	# 3. 恢复并显示探索地图和玩家 (完美保留在原位！)
	if current_map:
		current_map.show()
		current_map.process_mode = Node.PROCESS_MODE_INHERIT
	if player_instance:
		player_instance.show()
		player_instance.process_mode = Node.PROCESS_MODE_INHERIT
