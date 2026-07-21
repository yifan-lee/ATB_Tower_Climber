# res://scenes/battle.gd
extends Control

const BattleUIView = preload("res://ui/battle_ui_view.gd")

var player_stats: Stats
var enemy_stats: Stats
var enemy_id: String

var ui_view: BattleUIView

# --- ATB 进度条相关变量 ---
const BAR_WIDTH = GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE

var p_progress: float = 0.0
var e_progress: float = 0.0

var p_speed_px: float = 0.0
var e_speed_px: float = 0.0

var is_action_paused: bool = false
var ready_character: String = "" # 记录当前是谁走到了终点 ("player" 或 "enemy")

func setup(enemy_id: String):
	# 玩家共享全局属性，血量能在战斗之间继承
	player_stats = EntityDB.get_stats("player")
	
	# 怪物从数据库拿出来时深拷贝一份，这样每个怪物血量互相独立
	enemy_stats = EntityDB.get_stats(enemy_id).duplicate(true)
	
func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = ThemeConfig.COLOR_BATTLE_BG
	add_child(bg)
	
	ui_view = BattleUIView.new()
	add_child(ui_view)
	ui_view.setup(player_stats, enemy_stats)

	# 计算 ATB 移动速度 (像素/秒)
	p_speed_px = BAR_WIDTH * CombatFormula.get_atb_speed(player_stats.get_total_spd())
	e_speed_px = BAR_WIDTH * CombatFormula.get_atb_speed(enemy_stats.get_total_spd())

	EventBus.player_skill_chosen.connect(_on_player_skill_chosen)
	EventBus.player_item_used.connect(_on_player_item_used)
	EventBus.preview_skill.connect(_on_preview_skill)
	EventBus.clear_skill_preview.connect(_on_clear_skill_preview)

func _process(delta):
	var p_time = 0.0
	var e_time = 0.0
	
	if p_speed_px > 0:
		p_time = (BAR_WIDTH / p_speed_px) if p_progress >= BAR_WIDTH else max(0.0, (BAR_WIDTH - p_progress) / p_speed_px)
	
	if e_speed_px > 0:
		e_time = (BAR_WIDTH / e_speed_px) if e_progress >= BAR_WIDTH else max(0.0, (BAR_WIDTH - e_progress) / e_speed_px)

	ui_view.update_atb(p_progress, e_progress, p_time, e_time, p_speed_px, e_speed_px)

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
		var skills_info = []
		for skill in player_stats.skills:
			var estimated_dmg = CombatFormula.calculate_damage(player_stats.get_total_atk(), enemy_stats.get_total_def(), skill.damage)
			skills_info.append({
				"skill": skill,
				"estimated_damage": int(estimated_dmg)
			})
			
		EventBus.player_turn_started.emit(skills_info)
		
	# 判断怪物是否到达终点（如果同时到达，玩家优先）
	elif e_progress >= BAR_WIDTH:
		e_progress = BAR_WIDTH
		is_action_paused = true
		ready_character = "enemy"
		get_tree().create_timer(1.0).timeout.connect(_on_enemy_turn)
		
func _on_player_skill_chosen(skill: Skill):
	# 将刚选的技能进入CD
	skill.current_cd = skill.max_cd
	# 执行战斗逻辑
	var actual_dmg = _execute_skill(player_stats, enemy_stats, skill)
	EventBus.show_system_message.emit(["MSG_PLAYER_USED", skill.skill_name, "MSG_DAMAGE_CAUSED", str(actual_dmg), "MSG_DAMAGE_POINT"])
	
	if enemy_stats.current_hp <= 0:
		var gained_exp = enemy_stats.get_exp_yield()
		player_stats.gain_exp(gained_exp)
		EventBus.show_system_message.emit(["MSG_GAINED_EXP", str(gained_exp)])
		EventBus.battle_ended.emit("win")
	else:
		_resume_battle(true)

func _on_enemy_turn():
	var available_skills = enemy_stats.skills.filter(func(s): return s.current_cd <= 0 and enemy_stats.current_mp >= s.mana_cost)
	
	var chosen_skill = null
	if available_skills.size() > 0:
		chosen_skill = available_skills[randi() % available_skills.size()]
	elif enemy_stats.skills.size() > 0:
		chosen_skill = enemy_stats.skills[0]
		
	if chosen_skill != null:
		chosen_skill.current_cd = chosen_skill.max_cd
		var actual_dmg = _execute_skill(enemy_stats, player_stats, chosen_skill)
		EventBus.show_system_message.emit(["MSG_ENEMY_USED", chosen_skill.skill_name, "MSG_DAMAGE_CAUSED", str(actual_dmg), "MSG_DAMAGE_POINT"])
		
		if player_stats.current_hp <= 0:
			EventBus.battle_ended.emit("lose")
		else:
			_resume_battle(false)
	else:
		EventBus.show_system_message.emit(["MSG_ENEMY_SKIPPED"])
		_resume_battle(false)

func _execute_skill(attacker: Stats, defender: Stats, skill: Skill) -> int:
	attacker.current_mp = max(0, attacker.current_mp - skill.mana_cost)
	var final_damage = int(CombatFormula.calculate_damage(attacker.get_total_atk(), defender.get_total_def(), skill.damage))
	
	# 扣血并防止出现负数血量
	defender.current_hp = max(0, defender.current_hp - final_damage)
	
	# 刷新上方战斗面板的文字
	ui_view.update_stats(player_stats, enemy_stats)
	
	return final_damage

func _on_preview_skill(skill_data: Dictionary):
	var p_changes = skill_data.get("player_changes", {})
	var e_changes = skill_data.get("enemy_changes", {})
	ui_view.preview_stats(player_stats, p_changes, enemy_stats, e_changes)

func _on_clear_skill_preview():
	ui_view.update_stats(player_stats, enemy_stats)

func _resume_battle(was_player: bool):
	# 谁刚攻击完，谁的进度条清零
	if was_player:
		p_progress = 0.0
	else:
		e_progress = 0.0
		
	is_action_paused = false

func _on_player_item_used():
	ui_view.update_stats(player_stats, enemy_stats)
	
	if enemy_stats.current_hp <= 0:
		var gained_exp = enemy_stats.get_exp_yield()
		player_stats.gain_exp(gained_exp)
		EventBus.show_system_message.emit(["MSG_GAINED_EXP", str(gained_exp)])
		EventBus.battle_ended.emit("win")
	else:
		_resume_battle(true)
