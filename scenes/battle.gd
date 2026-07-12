# res://scenes/battle.gd
extends Control

var player_stats: Stats
var enemy_stats: Stats
var enemy_id: String

# --- ATB 进度条相关变量 ---
var bar_bg: ColorRect
const BAR_WIDTH = GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE

var p_pointer: AnimatedSprite2D
var e_pointer: AnimatedSprite2D

var p_progress: float = 0.0
var e_progress: float = 0.0

var p_speed_px: float = 0.0
var e_speed_px: float = 0.0

var is_action_paused: bool = false
var ready_character: String = "" # 记录当前是谁走到了终点 ("player" 或 "enemy")

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

	# 计算 ATB 移动速度 (像素/秒)
	p_speed_px = BAR_WIDTH * (100.0 + player_stats.spd) / 400.0
	e_speed_px = BAR_WIDTH * (100.0 + enemy_stats.spd) / 400.0


func _build_top_progress_bar():
	var bar_bg = ColorRect.new()
	bar_bg.size = Vector2(BAR_WIDTH, GameConfig.GRID_SIZE / 4)
	bar_bg.position = Vector2(GameConfig.GRID_SIZE / 2, GameConfig.GRID_SIZE / 2) # 居中留白
	bar_bg.color = Color(0.3, 0.3, 0.3)
	add_child(bar_bg)

	# 玩家指针 (进度条上方)
	p_pointer = GameConfig.create_scaled_anim_sprite(player_stats.anim_path, GameConfig.GRID_SIZE / 2)
	p_pointer.play("static") # 使用静止动画
	p_pointer.position = Vector2(0, -GameConfig.GRID_SIZE / 4) # 放在进度条上边缘
	bar_bg.add_child(p_pointer)

	# 怪物指针 (进度条上)
	e_pointer = GameConfig.create_scaled_anim_sprite(enemy_stats.anim_path, GameConfig.GRID_SIZE / 2)
	e_pointer.play("static") # 使用静止动画
	e_pointer.position = Vector2(0, GameConfig.GRID_SIZE / 4)
	bar_bg.add_child(e_pointer)

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
	# 1. 逃跑 (ESC)
	if event.is_action_pressed("ui_cancel"):
		EventBus.battle_ended.emit()

	# 2. 纯代码监听键盘数字 "1" 键
	# 确保是按下状态且不是长按产生的重复触发 (echo)
	if event is InputEventKey and event.keycode == KEY_1 and event.is_pressed() and not event.is_echo():
		# 只有在游戏暂停（有人走到终点）时，按 1 才有反应
		if is_action_paused:
			_execute_action_and_resume()

func _process(delta):
	# 如果有人走到终点了，暂停进度条
	if is_action_paused:
		return
		
	# 累加进度
	p_progress += p_speed_px * delta
	e_progress += e_speed_px * delta
	
	# 判断玩家是否到达终点
	if p_progress >= BAR_WIDTH:
		p_progress = BAR_WIDTH
		is_action_paused = true
		ready_character = "player"
		EventBus.show_system_message.emit("MSG_PLAYER_TURN") # 通知 UI 显示玩家回合
		
	# 判断怪物是否到达终点（如果同时到达，玩家优先）
	elif e_progress >= BAR_WIDTH:
		e_progress = BAR_WIDTH
		is_action_paused = true
		ready_character = "enemy"
		EventBus.show_system_message.emit("MSG_ENEMY_TURN") # 通知 UI 显示怪物回合
		
	# 实时更新指针的 X 坐标
	p_pointer.position.x = p_progress
	e_pointer.position.x = e_progress


func _execute_action_and_resume():
	# 这里预留给你以后写具体的攻击扣血逻辑
	# 比如：如果是 player，就放个攻击特效；如果是 enemy，就扣玩家的血
	# 动作执行完毕，重置当前行动者的进度条
	if ready_character == "player":
		p_progress = 0.0
	elif ready_character == "enemy":
		e_progress = 0.0
		
	# 清空状态，恢复游戏流动
	ready_character = ""
	is_action_paused = false
	
	# 通知下方 UI 进度条继续
	EventBus.show_system_message.emit("MSG_BATTLE_CONTINUE")
