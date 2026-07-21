# res://ui/info_panel.gd
extends PanelContainer

const EntityStatView = preload("res://ui/components/entity_stat_view.gd")

var floor_title_label: Label
var floor_desc_label: Label
var player_stat_view: EntityStatView

func _ready():
	# 给背景设置个深色底板
	var style = StyleBoxFlat.new()
	style.bg_color = ThemeConfig.COLOR_UI_BG_SOLID
	add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(main_vbox)
	
	# 上部分：动态信息 (左右分栏)
	var dynamic_hbox = HBoxContainer.new()
	dynamic_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dynamic_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(dynamic_hbox)
	
	# 左侧：楼层信息
	var left_vbox = VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.size_flags_vertical = Control.SIZE_FILL
	dynamic_hbox.add_child(left_vbox)
	
	floor_title_label = Label.new()
	floor_title_label.add_theme_color_override("font_color", ThemeConfig.COLOR_TEXT_HIGHLIGHT)
	left_vbox.add_child(floor_title_label)
	
	floor_desc_label = Label.new()
	floor_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	floor_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(floor_desc_label)
	
	# 右侧：EntityStatView 显示完整属性
	player_stat_view = EntityStatView.new()
	player_stat_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_stat_view.size_flags_vertical = Control.SIZE_FILL
	dynamic_hbox.add_child(player_stat_view)
	
	# 下部分：静态操作指南
	var static_guide = Label.new()
	static_guide.text = tr("UI_CONTROLS_GUIDE")
	static_guide.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	static_guide.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	static_guide.add_theme_color_override("font_color", ThemeConfig.COLOR_TEXT_DISABLED)
	main_vbox.add_child(static_guide)
	
	EventBus.player_stats_changed.connect(refresh_player_stats)
	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.game_loaded.connect(refresh_player_stats)

func refresh_floor_info(map_node: Node2D):
	if map_node and "floor_name_key" in map_node and "floor_desc_key" in map_node:
		floor_title_label.text = tr(map_node.floor_name_key)
		floor_desc_label.text = tr(map_node.floor_desc_key)
	else:
		floor_title_label.text = "???"
		floor_desc_label.text = ""

func refresh_player_stats():
	var stats = EntityDB.get_stats("player")
	if stats:
		player_stat_view.update_stats(stats, {}, true)

func _on_battle_ended(_result):
	refresh_player_stats()
