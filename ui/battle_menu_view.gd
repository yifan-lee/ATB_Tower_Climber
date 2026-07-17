# res://ui/battle_menu_view.gd
extends PanelContainer

var tabs_hbox: HBoxContainer
var skill_tab_label: Label
var item_tab_label: Label

var content_list_box: VBoxContainer
var desc_label: RichTextLabel

var is_menu_active: bool = false
var available_skills: Array = []
var available_items: Array = []
var filtered_items: Array = []
var current_selection: int = 0
var current_category_idx: int = 0

enum TabSide {SKILLS, ITEMS}
var current_tab: TabSide = TabSide.SKILLS

enum FocusState {FOCUS_TABS, FOCUS_CATEGORY, FOCUS_LIST}
var current_focus: FocusState = FocusState.FOCUS_LIST

var player_stats: Stats

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = ThemeConfig.COLOR_UI_BG_SOLID
	add_theme_stylebox_override("panel", style)

	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(main_vbox)

	# Tabs
	tabs_hbox = HBoxContainer.new()
	tabs_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_hbox.add_theme_constant_override("separation", 50)
	main_vbox.add_child(tabs_hbox)

	skill_tab_label = Label.new()
	skill_tab_label.text = tr("TAB_SKILLS")
	tabs_hbox.add_child(skill_tab_label)

	item_tab_label = Label.new()
	item_tab_label.text = tr("TAB_ITEMS")
	tabs_hbox.add_child(item_tab_label)

	# Content scroll area
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	content_list_box = VBoxContainer.new()
	content_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_list_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(content_list_box)

	# Description label
	desc_label = RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.custom_minimum_size = Vector2(0, 80)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(desc_label)

	EventBus.player_turn_started.connect(_on_player_turn_started)

func _on_player_turn_started(skills_info: Array):
	is_menu_active = true
	player_stats = EntityDB.get_stats("player")
	
	available_skills = skills_info
	
	current_tab = TabSide.SKILLS
	current_focus = FocusState.FOCUS_LIST
	current_category_idx = 0
	current_selection = 0
	
	_update_available_items()
	_refresh_view()

func _update_available_items():
	available_items.clear()
	for item_id in player_stats.inventory.keys():
		var count = player_stats.inventory[item_id]
		if count > 0:
			var item_data = ItemDB.get_item(item_id)
			available_items.append({"id": item_id, "data": item_data, "count": count})
			
	available_items.sort_custom(func(a, b): return a.data.type > b.data.type)

	var categories = UIUtils.get_inventory_categories()
	filtered_items = UIUtils.filter_items_by_category(available_items, categories[current_category_idx])

func _refresh_view():
	desc_label.text = ""
	
	if current_tab == TabSide.SKILLS:
		skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
		item_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		if current_focus == FocusState.FOCUS_TABS:
			skill_tab_label.text = "> " + TranslationServer.translate("TAB_SKILLS")
			skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			skill_tab_label.text = "   " + TranslationServer.translate("TAB_SKILLS")
			skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
			
		item_tab_label.text = "   " + TranslationServer.translate("TAB_ITEMS")
		item_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		# Boundary check
		if current_selection >= available_skills.size():
			current_selection = max(0, available_skills.size() - 1)
			
		var sel = current_selection if current_focus == FocusState.FOCUS_LIST else -1
		UIUtils.show_skill_list(content_list_box, available_skills, sel, desc_label, true)
		
	else:
		if current_focus == FocusState.FOCUS_TABS:
			item_tab_label.text = "> " + TranslationServer.translate("TAB_ITEMS")
			item_tab_label.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			item_tab_label.text = "   " + TranslationServer.translate("TAB_ITEMS")
			item_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
			
		skill_tab_label.text = "   " + TranslationServer.translate("TAB_SKILLS")
		skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		# Boundary check
		if current_selection >= filtered_items.size():
			current_selection = max(0, filtered_items.size() - 1)
			
		var is_cat_focused = (current_focus == FocusState.FOCUS_CATEGORY)
		var item_sel = current_selection if current_focus == FocusState.FOCUS_LIST else -1
		
		UIUtils.show_inventory_list(content_list_box, filtered_items, current_category_idx, item_sel, is_cat_focused, desc_label, true, true)


func _clear_menu():
	for child in content_list_box.get_children():
		child.queue_free()
	desc_label.text = ""

var input_cooldown: float = 0.0
const INPUT_DELAY: float = 0.15

func _process(delta: float):
	if not is_menu_active:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		if current_focus == FocusState.FOCUS_LIST:
			if current_tab == TabSide.SKILLS:
				if available_skills.size() > 0:
					var chosen_skill = available_skills[current_selection].skill
					if chosen_skill.current_cd <= 0:
						_close_menu()
						EventBus.player_skill_chosen.emit(chosen_skill)
			else:
				if filtered_items.size() > 0:
					var chosen_item_info = filtered_items[current_selection]
					if chosen_item_info.data.type == Item.ItemType.POTION:
						_use_item(chosen_item_info)
						_close_menu()
						EventBus.player_item_used.emit()
		return
		
	if input_cooldown > 0:
		input_cooldown -= delta
		return
		
	var moved = false
	if current_focus == FocusState.FOCUS_TABS:
		if GameConfig.is_pressing_left():
			if current_tab == TabSide.ITEMS:
				current_tab = TabSide.SKILLS
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_right():
			if current_tab == TabSide.SKILLS:
				current_tab = TabSide.ITEMS
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			if current_tab == TabSide.ITEMS:
				current_focus = FocusState.FOCUS_CATEGORY
				_refresh_view()
				moved = true
			else:
				if available_skills.size() > 0:
					current_focus = FocusState.FOCUS_LIST
					current_selection = 0
					_refresh_view()
					moved = true
	elif current_focus == FocusState.FOCUS_CATEGORY:
		var categories = UIUtils.get_inventory_categories()
		if GameConfig.is_pressing_up():
			if current_category_idx == 0:
				current_focus = FocusState.FOCUS_TABS
				_refresh_view()
				moved = true
			else:
				current_category_idx -= 1
				_update_available_items()
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			if current_category_idx < categories.size() - 1:
				current_category_idx += 1
				_update_available_items()
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_right():
			if filtered_items.size() > 0:
				current_focus = FocusState.FOCUS_LIST
				current_selection = 0
				_refresh_view()
				moved = true
	else: # FOCUS_LIST
		if GameConfig.is_pressing_up():
			if current_selection == 0:
				if current_tab == TabSide.ITEMS:
					current_focus = FocusState.FOCUS_CATEGORY
				else:
					current_focus = FocusState.FOCUS_TABS
				_refresh_view()
				moved = true
			else:
				current_selection -= 1
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			var max_len = filtered_items.size() if current_tab == TabSide.ITEMS else available_skills.size()
			if current_selection < max_len - 1:
				current_selection += 1
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_left():
			if current_tab == TabSide.ITEMS:
				current_focus = FocusState.FOCUS_CATEGORY
				_refresh_view()
				moved = true
			else:
				# from skills to tabs is up, left can be just go back to tabs or do nothing.
				pass
				
	if moved:
		input_cooldown = INPUT_DELAY

func _use_item(item_dict):
	var id = item_dict.id
	var item_data = item_dict.data
	
	if item_data.type == Item.ItemType.POTION:
		if player_stats.inventory[id] > 0:
			player_stats.inventory[id] -= 1
			player_stats.current_hp = min(player_stats.get_total_max_hp(), player_stats.current_hp + item_data.effect_hp)
			player_stats.current_mp = min(player_stats.get_total_max_mp(), player_stats.current_mp + item_data.effect_mp)
			EventBus.show_system_message.emit(["MSG_USED_ITEM", item_data.item_name])
			EventBus.player_stats_changed.emit()

func _close_menu():
	is_menu_active = false
	EventBus.clear_skill_preview.emit()
	EventBus.clear_preview.emit()
	_clear_menu()
