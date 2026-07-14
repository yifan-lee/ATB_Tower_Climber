# res://ui/info_panel.gd
extends Panel

const SystemMessageView = preload("res://ui/system_message_view.gd")
const SkillMenuView = preload("res://ui/skill_menu_view.gd")

func _ready():
	# 让整个 Panel 填满 UIContainer 的大小
	self.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", GameConfig.WALL_THICKNESS)
	margin_container.add_theme_constant_override("margin_top", GameConfig.WALL_THICKNESS)
	margin_container.add_theme_constant_override("margin_right", GameConfig.WALL_THICKNESS)
	margin_container.add_theme_constant_override("margin_bottom", GameConfig.WALL_THICKNESS)
	add_child(margin_container)
	
	var content_vbox = VBoxContainer.new()
	margin_container.add_child(content_vbox)
	
	var message_view = SystemMessageView.new()
	content_vbox.add_child(message_view)
	
	var skill_menu = SkillMenuView.new()
	content_vbox.add_child(skill_menu)
