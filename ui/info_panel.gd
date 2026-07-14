# res://ui/info_panel.gd
extends Panel

var margin_container: MarginContainer
var content_vbox: VBoxContainer
var message_label: Label
var skill_menu: HBoxContainer
var skill_list_box: VBoxContainer
var skill_desc_label: Label

var is_menu_active: bool = false
var available_skills: Array = []
var current_selection: int = 0
var skill_labels: Array = []

func _ready():
	# 让整个 Panel 填满 UIContainer 的大小
	self.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# # 给 Panel 设置一个深灰色背景，代替之前被删掉的 color 属性
	# var style = StyleBoxFlat.new()
	# style.bg_color = Color(0.15, 0.15, 0.15)
	# self.add_theme_stylebox_override("panel", style)
	
	margin_container = MarginContainer.new()
	_setup_margin_container()
	
	content_vbox = VBoxContainer.new()
	margin_container.add_child(content_vbox)
	
	_setup_message_container()
	_setup_skill_menu()

	# 监听全局消息信号
	EventBus.show_system_message.connect(_on_show_system_message)
	EventBus.show_skill_menu.connect(_on_show_skill_menu)
	EventBus.hide_skill_menu.connect(_on_hide_skill_menu)

func _setup_margin_container():
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", GameConfig.WALL_THICKNESS)
	margin_container.add_theme_constant_override("margin_top", GameConfig.WALL_THICKNESS)
	margin_container.add_theme_constant_override("margin_right", GameConfig.WALL_THICKNESS)
	margin_container.add_theme_constant_override("margin_bottom", GameConfig.WALL_THICKNESS)
	add_child(margin_container)

func _setup_message_container():
	message_label = Label.new()
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label.text = tr("MSG_WELCOME")
	content_vbox.add_child(message_label)

func _setup_skill_menu():
	skill_menu = HBoxContainer.new()
	skill_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_menu.size_flags_vertical = Control.SIZE_EXPAND_FILL
	skill_menu.visible = false # 初始隐藏
	content_vbox.add_child(skill_menu)

	skill_list_box = VBoxContainer.new()
	skill_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_menu.add_child(skill_list_box)

	skill_desc_label = Label.new()
	skill_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skill_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	skill_menu.add_child(skill_desc_label)
	
func _on_show_system_message(msg_key: String):
	message_label.show()
	message_label.text = tr(msg_key)

func _on_hide_skill_menu():
	is_menu_active = false
	skill_menu.visible = false

func _on_show_skill_menu(skills: Array):
	skill_menu.visible = true
	is_menu_active = true

	_clear_skill_buttons()
	
	available_skills = skills
	current_selection = 0
	
	# 纯代码动态生成技能条目
	for i in range(skills.size()):
		var skill = skills[i]
		var lbl = Label.new()
		# 如果冷却没好，显示CD
		if skill.current_cd > 0:
			lbl.text = "   " + tr(skill.skill_name) + " (CD:" + str(ceil(skill.current_cd)) + ")"
			lbl.modulate = Color(0.5, 0.5, 0.5) # 置灰
		else:
			lbl.text = "   " + tr(skill.skill_name)
			
		skill_list_box.add_child(lbl)
		skill_labels.append(lbl)
		
	_update_menu_cursor()

func _clear_skill_buttons():
	for child in skill_list_box.get_children():
		child.queue_free()
	skill_labels.clear()

func _update_menu_cursor():
	for i in range(available_skills.size()):
		var skill = available_skills[i]
		if i == current_selection:
			# 加上光标 >
			skill_labels[i].text = "> " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")
			skill_desc_label.text = tr(skill.description) + "\n" + tr("DISPLAY_DAMAGE") + str(skill.damage)
		else:
			# 移除光标
			skill_labels[i].text = "   " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")

# 纯代码拦截并处理键盘选择
func _input(event):
	if not is_menu_active:
		return
		
	if event.is_action_pressed("ui_up"):
		current_selection = max(0, current_selection - 1)
		_update_menu_cursor()
	elif event.is_action_pressed("ui_down"):
		current_selection = min(available_skills.size() - 1, current_selection + 1)
		_update_menu_cursor()
	elif event.is_action_pressed("ui_accept"): # 默认是空格或回车
		var chosen_skill = available_skills[current_selection]
		if chosen_skill.current_cd <= 0:
			is_menu_active = false
			# 向主战斗逻辑发送玩家的决定！
			EventBus.player_skill_chosen.emit(chosen_skill)
