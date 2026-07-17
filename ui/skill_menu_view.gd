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

	_setup_skill_list_box()
	_setup_desc_label_box()
	
	EventBus.player_turn_started.connect(_on_player_turn_started)

func _setup_skill_list_box():
	skill_list_box = VBoxContainer.new()
	skill_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_list_box.size_flags_vertical = Control.SIZE_FILL
	skill_list_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	add_child(skill_list_box)

func _setup_desc_label_box():
	skill_desc_label = Label.new()
	skill_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_desc_label.size_flags_vertical = Control.SIZE_FILL

	# 文本向上对齐
	skill_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	skill_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART # 自动换行防止穿帮

	# 直接塞进本脚本的 HBoxContainer 里
	add_child(skill_desc_label)

func _on_player_turn_started(skills_info: Array):
	is_menu_active = true

	_clear_skill_buttons()
	
	available_skills = skills_info
	current_selection = 0
	
	# 纯代码动态生成技能条目
	for i in range(skills_info.size()):
		var info = skills_info[i]
		var skill = info.skill
		var lbl = Label.new()
		if skill.current_cd > 0:
			lbl.text = "   " + tr(skill.skill_name) + " (CD:" + str(ceil(skill.current_cd)) + ")"
			lbl.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		else:
			lbl.text = "   " + tr(skill.skill_name)
			
		skill_list_box.add_child(lbl)
		skill_labels.append(lbl)
		
	_update_menu_cursor()

func _clear_skill_buttons():
	for child in skill_list_box.get_children():
		child.queue_free()
	skill_labels.clear()
	skill_desc_label.text = ""

func _update_menu_cursor():
	for i in range(available_skills.size()):
		var info = available_skills[i]
		var skill = info.skill
		if i == current_selection:
			skill_labels[i].text = "> " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")
			skill_desc_label.text = (
				tr(skill.description) + "\n" +
				tr("DISPLAY_DAMAGE") + str(skill.damage) + "\n" +
				tr("DISPLAY_MANA_COST") + str(skill.mana_cost) + "\n" +
				tr("DISPLAY_CD") + str(skill.max_cd)
			)
			EventBus.preview_skill.emit({
				"enemy_changes": {"hp": - info.estimated_damage},
				"player_changes": {"mp": - skill.mana_cost}
			})
		else:
			skill_labels[i].text = "   " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")

var input_cooldown: float = 0.0
const INPUT_DELAY: float = 0.15

func _process(delta: float):
	if not is_menu_active:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		var chosen_skill = available_skills[current_selection].skill
		if chosen_skill.current_cd <= 0:
			is_menu_active = false
			EventBus.clear_skill_preview.emit()
			_clear_skill_buttons()
			EventBus.player_skill_chosen.emit(chosen_skill)
		return
		
	if input_cooldown > 0:
		input_cooldown -= delta
		return
		
	var moved = false
	if GameConfig.is_pressing_up():
		current_selection = max(0, current_selection - 1)
		_update_menu_cursor()
		moved = true
	elif GameConfig.is_pressing_down():
		current_selection = min(available_skills.size() - 1, current_selection + 1)
		_update_menu_cursor()
		moved = true
		
	if moved:
		input_cooldown = INPUT_DELAY
