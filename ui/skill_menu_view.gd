# res://ui/skill_menu_view.gd
extends HBoxContainer

var skill_list_box: VBoxContainer
var skill_desc_label: Label

var is_menu_active: bool = false
var available_skills: Array = []
var current_selection: int = 0
var skill_labels: Array = []

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	visible = false # 初始隐藏
	
	skill_list_box = VBoxContainer.new()
	skill_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(skill_list_box)

	skill_desc_label = Label.new()
	skill_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skill_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(skill_desc_label)
	
	EventBus.show_skill_menu.connect(_on_show_skill_menu)
	EventBus.hide_skill_menu.connect(_on_hide_skill_menu)

func _on_hide_skill_menu():
	is_menu_active = false
	visible = false

func _on_show_skill_menu(skills: Array):
	visible = true
	is_menu_active = true

	_clear_skill_buttons()
	
	available_skills = skills
	current_selection = 0
	
	# 纯代码动态生成技能条目
	for i in range(skills.size()):
		var skill = skills[i]
		var lbl = Label.new()
		if skill.current_cd > 0:
			lbl.text = "   " + tr(skill.skill_name) + " (CD:" + str(ceil(skill.current_cd)) + ")"
			lbl.modulate = Color(0.5, 0.5, 0.5)
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
			skill_labels[i].text = "> " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")
			skill_desc_label.text = tr(skill.description) + "\n" + tr("DISPLAY_DAMAGE") + str(skill.damage)
		else:
			skill_labels[i].text = "   " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")

func _input(event):
	if not is_menu_active:
		return
		
	if event.is_action_pressed("ui_up"):
		current_selection = max(0, current_selection - 1)
		_update_menu_cursor()
	elif event.is_action_pressed("ui_down"):
		current_selection = min(available_skills.size() - 1, current_selection + 1)
		_update_menu_cursor()
	elif event.is_action_pressed("ui_accept"):
		var chosen_skill = available_skills[current_selection]
		if chosen_skill.current_cd <= 0:
			is_menu_active = false
			EventBus.player_skill_chosen.emit(chosen_skill)
