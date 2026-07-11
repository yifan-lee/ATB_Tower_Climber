# res://scenes/main.gd
extends Node

const MapFloor1 = preload("res://scenes/floor_1.gd")
const InfoPanel = preload("res://ui/info_panel.gd")
const Player = preload("res://entities/player.gd") # 预加载玩家脚本

@onready var game_container = $GameContainer
@onready var ui_container = $UIContainer

var current_map: Node2D
var player_instance: CharacterBody2D

func _ready():
    _setup_containers()
    _load_initial_scenes()

func _setup_containers():
    # 动态设置 GameContainer 尺寸
    game_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.EXPLORE_AREA_HEIGHT)
    game_container.position = Vector2(0, 0)
    
    # 动态设置 UIContainer 尺寸和位置
    ui_container.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.INFO_AREA_HEIGHT)
    ui_container.position = Vector2(0, GameConfig.EXPLORE_AREA_HEIGHT)

func _load_initial_scenes():
    # 1. 加载下方 UI
    var info_panel = InfoPanel.new()
    ui_container.add_child(info_panel)
    
    # 2. 加载地图 1 楼
    current_map = MapFloor1.new()
    game_container.add_child(current_map)
    
    # 3. 独立加载玩家角色
    player_instance = Player.new()
    # 将玩家放置在屏幕中央 (基于 GameConfig 配置的尺寸)
    player_instance.position = Vector2(
		GameConfig.WALL_THICKNESS + GameConfig.GRID_SIZE * (GameConfig.GRID_COLUMNS + 1.0) / 2.0 - GameConfig.GRID_SIZE / 2.0,
		GameConfig.WALL_THICKNESS + GameConfig.GRID_SIZE * (GameConfig.GRID_ROWS - 1.0) - GameConfig.GRID_SIZE / 2.0
	)
    
    # 将玩家也添加到 GameContainer，它与地图是分离的！
    game_container.add_child(player_instance)