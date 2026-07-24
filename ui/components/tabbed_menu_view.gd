# res://ui/components/tabbed_menu_view.gd
extends VBoxContainer
class_name TabbedMenuView

signal item_selected(item_dict: Dictionary)
signal skill_selected(skill_dict: Dictionary)
signal tab_changed(new_tab: int)
signal focus_changed(new_focus: int)
signal selection_changed(new_sel: int)

enum TabSide {ITEMS, SKILLS}
enum FocusState {FOCUS_TABS, FOCUS_CATEGORY, FOCUS_LIST}

var current_tab: TabSide = TabSide.ITEMS
var current_focus: FocusState = FocusState.FOCUS_TABS
var current_category_idx: int = 0
var current_selection: int = 0

var all_items: Array = []
var filtered_items: Array = []
var all_skills: Array = []

var tabs_hbox: HBoxContainer
var item_tab_label: Label
var skill_tab_label: Label
var content_list_box: VBoxContainer
var desc_label: RichTextLabel

var input_cooldown: float = 0.0
const INPUT_DELAY: float = 0.15

func _init():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Tabs
	tabs_hbox = HBoxContainer.new()
	tabs_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_hbox.add_theme_constant_override("separation", 50)
	add_child(tabs_hbox)

	item_tab_label = Label.new()
	item_tab_label.text = tr("TAB_ITEMS")
	tabs_hbox.add_child(item_tab_label)

	skill_tab_label = Label.new()
	skill_tab_label.text = tr("TAB_SKILLS")
	tabs_hbox.add_child(skill_tab_label)
	
	# Content scroll area
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	
	content_list_box = VBoxContainer.new()
	content_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_list_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(content_list_box)
	
	# Bottom Description
	desc_label = RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.custom_minimum_size = Vector2(0, 80)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(desc_label)

func set_data(items: Array, skills: Array):
	all_items = items
	all_skills = skills
	_update_filter()
	_refresh_view()

func reset_focus(tab: TabSide = TabSide.ITEMS, focus: FocusState = FocusState.FOCUS_TABS):
	current_tab = tab
	current_focus = focus
	current_category_idx = 0
	current_selection = 0
	
	if current_tab == TabSide.SKILLS and current_focus == FocusState.FOCUS_LIST and all_skills.size() == 0:
		current_focus = FocusState.FOCUS_TABS
		
	_update_filter()
	_refresh_view()

func refresh_keep_state(items: Array, skills: Array):
	all_items = items
	all_skills = skills
	_update_filter()
	
	if current_tab == TabSide.ITEMS:
		if current_selection >= filtered_items.size():
			current_selection = max(0, filtered_items.size() - 1)
		if filtered_items.size() == 0 and current_focus == FocusState.FOCUS_LIST:
			current_focus = FocusState.FOCUS_CATEGORY
	else:
		if current_selection >= all_skills.size():
			current_selection = max(0, all_skills.size() - 1)
		if all_skills.size() == 0 and current_focus == FocusState.FOCUS_LIST:
			current_focus = FocusState.FOCUS_TABS
			
	_refresh_view()

func _update_filter():
	var categories = UIUtils.get_inventory_categories()
	if current_category_idx >= categories.size():
		current_category_idx = 0
	filtered_items = UIUtils.filter_items_by_category(all_items, categories[current_category_idx])

func _refresh_view():
	desc_label.text = ""
	
	if current_tab == TabSide.ITEMS:
		if current_focus == FocusState.FOCUS_TABS:
			item_tab_label.text = "> " + tr("TAB_ITEMS")
			item_tab_label.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			item_tab_label.text = "   " + tr("TAB_ITEMS")
			item_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
			
		skill_tab_label.text = "   " + tr("TAB_SKILLS")
		skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		var is_cat_focused = (current_focus == FocusState.FOCUS_CATEGORY)
		var item_sel = current_selection if current_focus == FocusState.FOCUS_LIST else -1
		
		UIUtils.show_inventory_list(content_list_box, filtered_items, current_category_idx, item_sel, is_cat_focused, desc_label, false, true)
		
	else:
		if current_focus == FocusState.FOCUS_TABS:
			skill_tab_label.text = "> " + tr("TAB_SKILLS")
			skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			skill_tab_label.text = "   " + tr("TAB_SKILLS")
			skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
			
		item_tab_label.text = "   " + tr("TAB_ITEMS")
		item_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		var sel = current_selection if current_focus == FocusState.FOCUS_LIST else -1
		UIUtils.show_skill_list(content_list_box, all_skills, sel, desc_label, true)

func update_cooldowns_live(skills: Array):
	if current_tab == TabSide.SKILLS:
		UIUtils.update_skill_list_cooldowns(content_list_box, skills)

func _process(delta: float):
	if not visible:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		if current_focus == FocusState.FOCUS_LIST:
			if current_tab == TabSide.ITEMS and filtered_items.size() > 0:
				item_selected.emit(filtered_items[current_selection])
			elif current_tab == TabSide.SKILLS and all_skills.size() > 0:
				skill_selected.emit(all_skills[current_selection])
		return
		
	if input_cooldown > 0:
		input_cooldown -= delta
		return
		
	var moved = false
	if current_focus == FocusState.FOCUS_TABS:
		if GameConfig.is_pressing_left():
			if current_tab == TabSide.SKILLS:
				current_tab = TabSide.ITEMS
				tab_changed.emit(current_tab)
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_right():
			if current_tab == TabSide.ITEMS:
				current_tab = TabSide.SKILLS
				tab_changed.emit(current_tab)
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			if current_tab == TabSide.ITEMS:
				current_focus = FocusState.FOCUS_CATEGORY
				focus_changed.emit(current_focus)
				_refresh_view()
				moved = true
			else:
				if all_skills.size() > 0:
					current_focus = FocusState.FOCUS_LIST
					current_selection = 0
					focus_changed.emit(current_focus)
					selection_changed.emit(current_selection)
					_refresh_view()
					moved = true
	elif current_focus == FocusState.FOCUS_CATEGORY:
		var categories = UIUtils.get_inventory_categories()
		if GameConfig.is_pressing_up():
			if current_category_idx == 0:
				current_focus = FocusState.FOCUS_TABS
				focus_changed.emit(current_focus)
				_refresh_view()
				moved = true
			else:
				current_category_idx -= 1
				_update_filter()
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			if current_category_idx < categories.size() - 1:
				current_category_idx += 1
				_update_filter()
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_right():
			if filtered_items.size() > 0:
				current_focus = FocusState.FOCUS_LIST
				current_selection = 0
				focus_changed.emit(current_focus)
				selection_changed.emit(current_selection)
				_refresh_view()
				moved = true
	else: # FOCUS_LIST
		if GameConfig.is_pressing_up():
			if current_selection == 0:
				if current_tab == TabSide.ITEMS:
					current_focus = FocusState.FOCUS_CATEGORY
				else:
					current_focus = FocusState.FOCUS_TABS
				focus_changed.emit(current_focus)
				_refresh_view()
				moved = true
			else:
				current_selection -= 1
				selection_changed.emit(current_selection)
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			var max_len = filtered_items.size() if current_tab == TabSide.ITEMS else all_skills.size()
			if current_selection < max_len - 1:
				current_selection += 1
				selection_changed.emit(current_selection)
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_left():
			if current_tab == TabSide.ITEMS:
				current_focus = FocusState.FOCUS_CATEGORY
				focus_changed.emit(current_focus)
				_refresh_view()
				moved = true
			else:
				current_focus = FocusState.FOCUS_TABS
				focus_changed.emit(current_focus)
				_refresh_view()
				moved = true
				
	if moved:
		input_cooldown = INPUT_DELAY
