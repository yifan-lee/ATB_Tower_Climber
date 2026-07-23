# res://ui/battle_ui_view.gd
extends Control
class_name BattleUIView

const EntityStatView = preload("res://ui/components/entity_stat_view.gd")
const BAR_WIDTH = GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE

var p_pointer: AnimatedSprite2D
var e_pointer: AnimatedSprite2D
var p_time_label: Label
var e_time_label: Label

var p_stat_view: EntityStatView
var e_stat_view: EntityStatView

var p_anim: AnimatedSprite2D
var e_anim: AnimatedSprite2D

func _init():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func setup(player_stats: Stats, enemy_stats: Stats):
	_build_top_progress_bar(player_stats, enemy_stats)
	_build_middle_stats(player_stats, enemy_stats)
	_build_bottom_animations(player_stats, enemy_stats)

func _build_top_progress_bar(player_stats: Stats, enemy_stats: Stats):
	var bar_bg = ColorRect.new()
	bar_bg.size = Vector2(BAR_WIDTH, GameConfig.GRID_SIZE / 4)
	bar_bg.position = Vector2(GameConfig.GRID_SIZE / 2, GameConfig.GRID_SIZE / 2) # 居中留白
	bar_bg.color = ThemeConfig.COLOR_BAR_BG
	add_child(bar_bg)

	# 玩家指针 (进度条上方)
	p_pointer = GameConfig.create_scaled_anim_sprite(player_stats.anim_path, GameConfig.GRID_SIZE / 2)
	p_pointer.play("static") # 使用静止动画
	p_pointer.position = Vector2(0, -GameConfig.GRID_SIZE / 4) # 放在进度条上边缘
	bar_bg.add_child(p_pointer)
	
	p_time_label = Label.new()
	p_time_label.position = Vector2(-30, -GameConfig.GRID_SIZE / 4)
	p_time_label.add_theme_font_size_override("font_size", 12)
	bar_bg.add_child(p_time_label)

	# 怪物指针 (进度条上)
	e_pointer = GameConfig.create_scaled_anim_sprite(enemy_stats.anim_path, GameConfig.GRID_SIZE / 2)
	e_pointer.play("static") # 使用静止动画
	e_pointer.position = Vector2(0, GameConfig.GRID_SIZE / 4)
	bar_bg.add_child(e_pointer)
	
	e_time_label = Label.new()
	e_time_label.position = Vector2(-30, GameConfig.GRID_SIZE / 4)
	e_time_label.add_theme_font_size_override("font_size", 12)
	bar_bg.add_child(e_time_label)

func _build_middle_stats(player_stats: Stats, enemy_stats: Stats):
	var hbox = HBoxContainer.new()
	hbox.size = Vector2(GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE, 2 * GameConfig.GRID_SIZE)
	hbox.position = Vector2(GameConfig.GRID_SIZE / 2, GameConfig.GRID_SIZE)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", GameConfig.GRID_SIZE) # 左右间距
	add_child(hbox)

	p_stat_view = EntityStatView.new()
	hbox.add_child(p_stat_view)
	p_stat_view.update_stats(player_stats)
	
	e_stat_view = EntityStatView.new()
	hbox.add_child(e_stat_view)
	e_stat_view.update_stats(enemy_stats)
	
	var basic_atk_skill = SkillDB.get_skill("basic_atk")
	
	var expected_p_dmg = ceil(GameRules.calculate_damage(player_stats.get_total_atk(), enemy_stats.get_total_def(), basic_atk_skill.damage))
	p_stat_view.set_extra_info(TranslationServer.translate("EXPECTED_DMG") + ": [color=red]" + str(expected_p_dmg) + "[/color]")
	
	var expected_e_dmg = ceil(GameRules.calculate_damage(enemy_stats.get_total_atk(), player_stats.get_total_def(), basic_atk_skill.damage))
	e_stat_view.set_extra_info(TranslationServer.translate("EXPECTED_DMG") + ": [color=red]" + str(expected_e_dmg) + "[/color]")

func _build_bottom_animations(player_stats: Stats, enemy_stats: Stats):
	p_anim = GameConfig.create_scaled_anim_sprite(player_stats.anim_path, GameConfig.GRID_SIZE, "combat_idle")
	p_anim.position = Vector2(
		GameConfig.GRID_SIZE + GameConfig.WALL_THICKNESS,
		GameConfig.GAME_AREA_HEIGHT - GameConfig.WALL_THICKNESS - GameConfig.GRID_SIZE
	)
	add_child(p_anim)
	
	e_anim = GameConfig.create_scaled_anim_sprite(enemy_stats.anim_path, GameConfig.GRID_SIZE, "combat_idle")
	e_anim.flip_h = true
	e_anim.position = Vector2(
		GameConfig.SCREEN_WIDTH - GameConfig.GRID_SIZE - GameConfig.WALL_THICKNESS,
		GameConfig.GAME_AREA_HEIGHT - GameConfig.WALL_THICKNESS - GameConfig.GRID_SIZE
	)
	add_child(e_anim)

func update_atb(p_progress: float, e_progress: float, p_time: float, e_time: float, p_speed_px: float, e_speed_px: float):
	p_pointer.position.x = p_progress
	e_pointer.position.x = e_progress

	if p_speed_px > 0:
		p_time_label.text = "%.1fs" % p_time
	
	if e_speed_px > 0:
		e_time_label.text = "%.1fs" % e_time

func update_stats(player_stats: Stats, enemy_stats: Stats):
	p_stat_view.update_stats(player_stats)
	e_stat_view.update_stats(enemy_stats)

func preview_stats(player_stats: Stats, p_changes: Dictionary, enemy_stats: Stats, e_changes: Dictionary):
	if not p_changes.is_empty():
		p_stat_view.update_stats(player_stats, p_changes)
	else:
		p_stat_view.update_stats(player_stats)
		
	if not e_changes.is_empty():
		e_stat_view.update_stats(enemy_stats, e_changes)
	else:
		e_stat_view.update_stats(enemy_stats)
