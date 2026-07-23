# res://ui/info_panel.gd
extends PanelContainer

const EntityStatView = preload("res://ui/components/entity_stat_view.gd")
const MaterialView = preload("res://ui/components/material_view.gd")

var floor_title_label: Label
var floor_desc_label: Label
var player_stat_view: EntityStatView
var material_separator: HSeparator
var material_view: MaterialView

var current_preview: Dictionary = {}

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
	
	# 右侧：属性与材料 (VBox 结构)
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = Control.SIZE_FILL
	dynamic_hbox.add_child(right_vbox)
	
	player_stat_view = EntityStatView.new()
	player_stat_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_stat_view.size_flags_vertical = Control.SIZE_FILL
	right_vbox.add_child(player_stat_view)
	
	material_separator = HSeparator.new()
	right_vbox.add_child(material_separator)
	
	material_view = MaterialView.new()
	material_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	material_view.size_flags_vertical = Control.SIZE_FILL
	right_vbox.add_child(material_view)
	
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
	EventBus.preview_interaction.connect(_on_preview_interaction)
	EventBus.clear_preview_interaction.connect(_on_clear_preview_interaction)

func _on_preview_interaction(expected_changes: Dictionary):
	current_preview = expected_changes
	refresh_player_stats()

func _on_clear_preview_interaction():
	current_preview = {}
	refresh_player_stats()

func refresh_floor_info(map_node: Node2D):
	if map_node and "config" in map_node:
		var floor_num = map_node.config.get("floor", 0)
		var floor_name = tr(map_node.config.get("name", "MAP_FLOOR_UNKNOWN"))
		floor_title_label.text = "%s%d: %s" % [tr("MSG_FLOOR_PREFIX"), floor_num, floor_name]
		floor_desc_label.text = tr(map_node.config.get("desc", "MAP_DESC_UNKNOWN"))
	else:
		floor_title_label.text = "???"
		floor_desc_label.text = ""

func refresh_player_stats():
	var stats = EntityDB.get_stats("player")
	if stats:
		player_stat_view.update_stats(stats, current_preview, true)
		material_view.update_materials(stats.inventory, current_preview)
		material_separator.visible = material_view.visible

func _on_battle_ended(_result):
	refresh_player_stats()
