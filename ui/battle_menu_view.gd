# res://ui/battle_menu_view.gd
extends PanelContainer

var tabbed_menu: TabbedMenuView

var is_menu_active: bool = false
var available_skills: Array = []

var player_stats: Stats

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = ThemeConfig.COLOR_UI_BG_SOLID
	add_theme_stylebox_override("panel", style)

	tabbed_menu = TabbedMenuView.new()
	add_child(tabbed_menu)
	
	tabbed_menu.item_selected.connect(_on_item_selected)
	tabbed_menu.skill_selected.connect(_on_skill_selected)
	tabbed_menu.tab_changed.connect(_on_tab_changed)
	tabbed_menu.focus_changed.connect(_on_focus_changed)
	
	EventBus.player_turn_started.connect(_on_player_turn_started)
	EventBus.game_loaded.connect(_on_game_loaded)

func _on_player_turn_started(skills_info: Array):
	is_menu_active = true
	player_stats = EntityDB.get_stats("player")
	available_skills = skills_info
	
	_update_data_and_refresh(true)

func _update_data_and_refresh(reset_focus: bool = false):
	var current_items = []
	for item_id in player_stats.inventory.keys():
		var count = player_stats.inventory[item_id]
		if count > 0:
			var item_data = ItemDB.get_item(item_id)
			current_items.append({"id": item_id, "data": item_data, "count": count})
			
	current_items.sort_custom(func(a, b): return a.data.type > b.data.type)

	if reset_focus:
		tabbed_menu.set_data(current_items, available_skills)
		tabbed_menu.reset_focus(TabbedMenuView.TabSide.SKILLS, TabbedMenuView.FocusState.FOCUS_LIST)
	else:
		tabbed_menu.refresh_keep_state(current_items, available_skills)

func _on_item_selected(item_dict):
	if not is_menu_active: return
	var item_data = item_dict.data
	if item_data.type == Item.ItemType.POTION:
		_use_item(item_dict)
		is_menu_active = false
		EventBus.clear_skill_preview.emit()
		EventBus.clear_preview.emit()
		EventBus.player_item_used.emit()

func _on_skill_selected(skill_dict):
	if not is_menu_active: return
	var chosen_skill = skill_dict.skill
	if chosen_skill.current_cd <= 0:
		is_menu_active = false
		EventBus.clear_skill_preview.emit()
		EventBus.clear_preview.emit()
		EventBus.player_skill_chosen.emit(chosen_skill)

func _use_item(item_dict):
	var id = item_dict.id
	var item_data = item_dict.data
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
	tabbed_menu.visible = false

func _on_tab_changed(new_tab):
	if not is_menu_active: return
	if new_tab == TabbedMenuView.TabSide.SKILLS:
		EventBus.clear_preview.emit()
	else:
		EventBus.clear_skill_preview.emit()

func _on_focus_changed(new_focus):
	if not is_menu_active: return
	if new_focus != TabbedMenuView.FocusState.FOCUS_LIST:
		EventBus.clear_preview.emit()
		EventBus.clear_skill_preview.emit()

func _on_game_loaded():
	if is_menu_active:
		player_stats = EntityDB.get_stats("player")
		_update_data_and_refresh(false)

func _process(_delta):
	if is_menu_active and not tabbed_menu.visible:
		tabbed_menu.visible = true
	
	if tabbed_menu.visible and player_stats != null:
		tabbed_menu.update_cooldowns_live(available_skills)
