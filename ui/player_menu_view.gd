# res://ui/player_menu_view.gd
extends PanelContainer

var player_stats: Stats

var content_list_box: VBoxContainer
var desc_label: RichTextLabel

var tabs_hbox: HBoxContainer
var item_tab_label: Label
var skill_tab_label: Label

enum FocusState {FOCUS_TABS, FOCUS_CATEGORY, FOCUS_LIST}
var current_focus: FocusState = FocusState.FOCUS_TABS

enum TabSide {ITEMS, SKILLS}
var current_tab: TabSide = TabSide.ITEMS

var current_category_idx: int = 0
var current_items = []
var filtered_items = []
var current_skills = []
var current_selection: int = 0

func _ready():
	visible = false
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = ThemeConfig.COLOR_UI_BG_SOLID
	add_theme_stylebox_override("panel", style)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(main_vbox)
	
	player_stats = EntityDB.get_stats("player")
	
	EventBus.game_loaded.connect(_on_game_loaded)
	
	# Top Tabs
	tabs_hbox = HBoxContainer.new()
	tabs_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_hbox.add_theme_constant_override("separation", 50)
	main_vbox.add_child(tabs_hbox)

	item_tab_label = Label.new()
	item_tab_label.text = tr("TAB_ITEMS")
	tabs_hbox.add_child(item_tab_label)

	skill_tab_label = Label.new()
	skill_tab_label.text = tr("TAB_SKILLS")
	tabs_hbox.add_child(skill_tab_label)
	
	# Center List area
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	content_list_box = VBoxContainer.new()
	content_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_list_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(content_list_box)
	
	# Bottom Description
	desc_label = RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.custom_minimum_size = Vector2(0, 80)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(desc_label)

func refresh():
	current_focus = FocusState.FOCUS_TABS
	current_tab = TabSide.ITEMS
	current_category_idx = 0
	current_selection = 0
	_update_data()
	_refresh_view()

func clear():
	EventBus.clear_preview.emit()

func _update_data():
	current_items.clear()
	for item_id in player_stats.inventory.keys():
		var count = player_stats.inventory[item_id]
		if count > 0:
			var item_data = ItemDB.get_item(item_id)
			current_items.append({"id": item_id, "data": item_data, "count": count})
			
	current_items.sort_custom(func(a, b): return a.data.type > b.data.type)

	var categories = UIUtils.get_inventory_categories()
	filtered_items = UIUtils.filter_items_by_category(current_items, categories[current_category_idx])

	current_skills.clear()
	if player_stats.skills:
		for skill in player_stats.skills:
			current_skills.append(skill)

func _refresh_view():
	desc_label.text = ""
	
	if current_tab == TabSide.ITEMS:
		if current_focus == FocusState.FOCUS_TABS:
			item_tab_label.text = "> " + TranslationServer.translate("TAB_ITEMS")
			item_tab_label.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			item_tab_label.text = "   " + TranslationServer.translate("TAB_ITEMS")
			item_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
			
		skill_tab_label.text = "   " + TranslationServer.translate("TAB_SKILLS")
		skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		var is_cat_focused = (current_focus == FocusState.FOCUS_CATEGORY)
		var item_sel = current_selection if current_focus == FocusState.FOCUS_LIST else -1
		
		UIUtils.show_inventory_list(content_list_box, filtered_items, current_category_idx, item_sel, is_cat_focused, desc_label, false, true)
		
	else:
		if current_focus == FocusState.FOCUS_TABS:
			skill_tab_label.text = "> " + TranslationServer.translate("TAB_SKILLS")
			skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			skill_tab_label.text = "   " + TranslationServer.translate("TAB_SKILLS")
			skill_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
			
		item_tab_label.text = "   " + TranslationServer.translate("TAB_ITEMS")
		item_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		var sel = current_selection if current_focus == FocusState.FOCUS_LIST else -1
		UIUtils.show_skill_list(content_list_box, current_skills, sel, desc_label, true)

var input_cooldown: float = 0.0
const INPUT_DELAY: float = 0.15

func _process(delta: float):
	if not visible:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		if current_focus == FocusState.FOCUS_LIST and current_tab == TabSide.ITEMS and filtered_items.size() > 0:
			_use_item(filtered_items[current_selection])
		return
		
	if input_cooldown > 0:
		input_cooldown -= delta
		return
		
	var moved = false
	if current_focus == FocusState.FOCUS_TABS:
		if GameConfig.is_pressing_left():
			if current_tab == TabSide.SKILLS:
				current_tab = TabSide.ITEMS
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_right():
			if current_tab == TabSide.ITEMS:
				current_tab = TabSide.SKILLS
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			if current_tab == TabSide.ITEMS:
				current_focus = FocusState.FOCUS_CATEGORY
				_refresh_view()
				moved = true
			else:
				if current_skills.size() > 0:
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
				_update_data()
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_down():
			if current_category_idx < categories.size() - 1:
				current_category_idx += 1
				_update_data()
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
			var max_len = filtered_items.size() if current_tab == TabSide.ITEMS else current_skills.size()
			if current_selection < max_len - 1:
				current_selection += 1
				_refresh_view()
				moved = true
		elif GameConfig.is_pressing_left():
			if current_tab == TabSide.ITEMS:
				current_focus = FocusState.FOCUS_CATEGORY
				_refresh_view()
				moved = true
				
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
			_update_data()
			
			if current_selection >= filtered_items.size():
				current_selection = max(0, filtered_items.size() - 1)
			if filtered_items.size() == 0:
				current_focus = FocusState.FOCUS_CATEGORY
				
			_refresh_view()
	elif item_data.type == Item.ItemType.EQUIPMENT:
		if player_stats.inventory[id] > 0:
			var slot = item_data.equip_slot
			var old_equip = player_stats.equipment[slot]
			var delta_hp = item_data.effect_hp - (old_equip.effect_hp if old_equip else 0)
			var delta_mp = item_data.effect_mp - (old_equip.effect_mp if old_equip else 0)
			
			if old_equip != null:
				var old_id = old_equip.item_id
				if player_stats.inventory.has(old_id):
					player_stats.inventory[old_id] += 1
				else:
					player_stats.inventory[old_id] = 1
					
			player_stats.inventory[id] -= 1
			player_stats.equipment[slot] = item_data
			
			player_stats.current_hp = max(1, player_stats.current_hp + delta_hp)
			player_stats.current_mp = max(0, player_stats.current_mp + delta_mp)
			
			player_stats.current_hp = min(player_stats.current_hp, player_stats.get_total_max_hp())
			player_stats.current_mp = min(player_stats.current_mp, player_stats.get_total_max_mp())
			
			EventBus.show_system_message.emit(["MSG_EQUIPPED", item_data.item_name])
			EventBus.player_stats_changed.emit()
			_update_data()
			
			if current_selection >= filtered_items.size():
				current_selection = max(0, filtered_items.size() - 1)
			if filtered_items.size() == 0:
				current_focus = FocusState.FOCUS_CATEGORY
				
			_refresh_view()

func _on_game_loaded():
	player_stats = EntityDB.get_stats("player")
	if visible:
		refresh()
