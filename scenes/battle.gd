# res://scenes/battle.gd
extends Control

var player_stats: Stats
var enemy_stats: Stats
var enemy_id: String

func setup(enemy_id: String):
	player_stats = EntityDB.get_stats("player")
	enemy_stats = EntityDB.get_stats(enemy_id)
	
	
func _ready():
	custom_minimum_size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.EXPLORE_AREA_HEIGHT)
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.1, 0.15)
	add_child(bg)
	
	_build_top_progress_bar()
	_build_middle_stats()
	_build_bottom_animations()


func _build_top_progress_bar():
	var bar_bg = ColorRect.new()
	bar_bg.size = Vector2(GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE, GameConfig.GRID_SIZE / 2)
	bar_bg.position = Vector2(GameConfig.GRID_SIZE / 2, GameConfig.GRID_SIZE / 2) # 居中留白
	bar_bg.color = Color(0.3, 0.3, 0.3)
	add_child(bar_bg)

func _build_middle_stats():
	var hbox = HBoxContainer.new()
	hbox.size = Vector2(GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE, 2 * GameConfig.GRID_SIZE)
	hbox.position = Vector2(GameConfig.GRID_SIZE / 2, GameConfig.GRID_SIZE)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", GameConfig.GRID_SIZE) # 左右间距
	add_child(hbox)

	hbox.add_child(_create_stat_panel(player_stats))
	hbox.add_child(_create_stat_panel(enemy_stats))

func _create_stat_panel(stats: Stats) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.add_child(_create_label(stats.entity_name, Color(1, 1, 0))) # 名字标黄
	vbox.add_child(_create_label("HP: " + str(stats.max_hp) + "/" + str(stats.max_hp)))
	vbox.add_child(_create_label("ATK: " + str(stats.atk)))
	vbox.add_child(_create_label("DEF: " + str(stats.def)))
	vbox.add_child(_create_label("SPD: " + str(stats.spd)))
	return vbox

func _create_label(text: String, color: Color = Color.WHITE) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	return lbl


func _build_bottom_animations():
	# 左侧玩家动画 (我们在战斗画面让它大一点，比如占据 2 个格子的尺寸: 128x128)
	var p_anim = GameConfig.create_scaled_anim_sprite(player_stats.anim_path, GameConfig.GRID_SIZE * 2)
	p_anim.position = Vector2(
		GameConfig.GRID_SIZE + GameConfig.WALL_THICKNESS,
		GameConfig.EXPLORE_AREA_HEIGHT - GameConfig.WALL_THICKNESS - GameConfig.GRID_SIZE
	)
	add_child(p_anim)
	
	# 右侧怪物动画 (同样 128x128)
	var e_anim = GameConfig.create_scaled_anim_sprite(enemy_stats.anim_path, GameConfig.GRID_SIZE * 2)
	e_anim.position = Vector2(
		GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE - GameConfig.WALL_THICKNESS,
		GameConfig.EXPLORE_AREA_HEIGHT - GameConfig.WALL_THICKNESS - GameConfig.GRID_SIZE
	)
	add_child(e_anim)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ui_cancel 默认绑定的是 ESC 键
		EventBus.battle_ended.emit()
