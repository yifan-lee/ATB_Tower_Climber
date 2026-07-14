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


var p_hp_label: Label
var e_hp_label: Label

func setup(enemy_id: String):
	# 玩家共享全局属性，血量能在战斗之间继承
	player_stats = EntityDB.get_stats("player")
	
	# 怪物从数据库拿出来时深拷贝一份，这样每个怪物血量互相独立
	enemy_stats = EntityDB.get_stats(enemy_id).duplicate(true)
	
	
func _ready():
	custom_minimum_size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT)
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.1, 0.15)
	add_child(bg)
	
	_build_top_progress_bar()
	_build_middle_stats()
	_build_bottom_animations()

	# 计算 ATB 移动速度 (像素/秒)
	p_speed_px = BAR_WIDTH * (100.0 + player_stats.get_total_spd()) / 400.0
	e_speed_px = BAR_WIDTH * (100.0 + enemy_stats.get_total_spd()) / 400.0

	EventBus.player_skill_chosen.connect(_on_player_skill_chosen)
	

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

	hbox.add_child(_create_stat_panel(player_stats, true))
	hbox.add_child(_create_stat_panel(enemy_stats, false))

func _create_stat_panel(stats: Stats, is_player: bool) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.add_child(_create_label(stats.entity_name, Color(1, 1, 0))) # 名字标黄
	var hp_lbl = _create_label(
		"HP: " + str(stats.current_hp) + "/" + str(stats.get_total_max_hp()) + "\n" +
		"MP: " + str(stats.current_mp) + "/" + str(stats.get_total_max_mp())
	)
	vbox.add_child(hp_lbl)
	if is_player:
		p_hp_label = hp_lbl
	else:
		e_hp_label = hp_lbl
	vbox.add_child(_create_label("ATK: " + str(stats.get_total_atk())))
	vbox.add_child(_create_label("DEF: " + str(stats.get_total_def())))
	vbox.add_child(_create_label("SPD: " + str(stats.get_total_spd())))
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
		GameConfig.GAME_AREA_HEIGHT - GameConfig.WALL_THICKNESS - GameConfig.GRID_SIZE
	)
	add_child(p_anim)
	
	# 右侧怪物动画 (同样 128x128)
	var e_anim = GameConfig.create_scaled_anim_sprite(enemy_stats.anim_path, GameConfig.GRID_SIZE * 2)
	e_anim.position = Vector2(
		GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE - GameConfig.WALL_THICKNESS,
		GameConfig.GAME_AREA_HEIGHT - GameConfig.WALL_THICKNESS - GameConfig.GRID_SIZE
	)
	add_child(e_anim)


func _process(delta):
	# 如果有人走到终点了，暂停进度条
	if is_action_paused:
		return
		
	# 累加进度
	p_progress += p_speed_px * delta
	e_progress += e_speed_px * delta
	
	# 技能冷却
	if player_stats.skills != null:
		for skill in player_stats.skills:
			if skill.current_cd > 0:
				skill.current_cd = max(0.0, skill.current_cd - delta)
				
	if enemy_stats.skills != null:
		for skill in enemy_stats.skills:
			if skill.current_cd > 0:
				skill.current_cd = max(0.0, skill.current_cd - delta)
	
	# 判断玩家是否到达终点
	if p_progress >= BAR_WIDTH:
		p_progress = BAR_WIDTH
		is_action_paused = true
		ready_character = "player"
		EventBus.show_system_message.emit("MSG_PLAYER_TURN") # 通知 UI 显示玩家回合
		var skills_info = []
		for skill in player_stats.skills:
			var estimated_dmg = _get_attack_damage(player_stats.get_total_atk(), enemy_stats.get_total_def(), skill.damage)
			skills_info.append({
				"skill": skill,
				"estimated_damage": int(estimated_dmg)
			})
			
		EventBus.show_skill_menu.emit(skills_info)
		
	# 判断怪物是否到达终点（如果同时到达，玩家优先）
	elif e_progress >= BAR_WIDTH:
		e_progress = BAR_WIDTH
		is_action_paused = true
		ready_character = "enemy"
		EventBus.show_system_message.emit("MSG_ENEMY_TURN") # 通知 UI 显示怪物回合
		get_tree().create_timer(1.0).timeout.connect(_enemy_action)
		
	# 实时更新指针的 X 坐标
	p_pointer.position.x = p_progress
	e_pointer.position.x = e_progress

func _on_player_skill_chosen(skill: Skill):
	# 将刚选的技能进入CD
	skill.current_cd = skill.max_cd
	# 执行战斗逻辑
	_execute_skill(player_stats, enemy_stats, skill)

func _enemy_action():
	# 5. 怪物默认只会使用普通攻击（数组里的第0个技能）
	# 以后如果你想加 AI，只需在这里写逻辑去选别的 index
	var chosen_skill = enemy_stats.skills[0]
	_execute_skill(enemy_stats, player_stats, chosen_skill)

func _execute_skill(attacker: Stats, defender: Stats, skill: Skill):
	var final_damage = _get_attack_damage(attacker.get_total_atk(), defender.get_total_def(), skill.damage)
	
	# 扣血并防止出现负数血量
	defender.current_hp = max(0, defender.current_hp - final_damage)
	
	# 刷新上方战斗面板的文字
	p_hp_label.text = (
		"HP: " + str(player_stats.current_hp) + "/" + str(player_stats.get_total_max_hp()) + "\n" +
		"MP: " + str(player_stats.current_mp) + "/" + str(player_stats.get_total_max_mp())
	)
	e_hp_label.text = (
		"HP: " + str(enemy_stats.current_hp) + "/" + str(enemy_stats.get_total_max_hp()) + "\n" +
		"MP: " + str(enemy_stats.current_mp) + "/" + str(enemy_stats.get_total_max_mp())
	)
	
	if defender.current_hp <= 0:
		if defender == enemy_stats:
			EventBus.battle_ended.emit("win")
		else:
			EventBus.battle_ended.emit("lose")
		return
		
	# 可以在这里发信号让 UI 显示 "玩家使用了 重击，造成了 15 点伤害！"
	# 这里为了简便，直接恢复战斗进度条
	_resume_battle(attacker == player_stats)

func _get_attack_damage(atk: int, def: int, skill_damage: int) -> float:
	return max(1, atk / 100.0 * skill_damage * (100.0 / (100.0 + def)))

func _resume_battle(was_player: bool):
	# 谁刚攻击完，谁的进度条清零
	if was_player:
		p_progress = 0.0
	else:
		e_progress = 0.0
		
	is_action_paused = false
	EventBus.show_system_message.emit("MSG_BATTLE_CONTINUE")
