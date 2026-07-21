# res://ui/player_menu_view.gd
extends PanelContainer

var player_stats: Stats
var tabbed_menu: TabbedMenuView

func _ready():
	visible = false
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = ThemeConfig.COLOR_UI_BG_SOLID
	add_theme_stylebox_override("panel", style)
	
	tabbed_menu = TabbedMenuView.new()
	add_child(tabbed_menu)
	
	tabbed_menu.item_selected.connect(_on_item_selected)
	
	player_stats = EntityDB.get_stats("player")
	EventBus.game_loaded.connect(_on_game_loaded)

func refresh():
	_update_data_and_refresh(true)

func clear():
	EventBus.clear_preview.emit()

func _update_data_and_refresh(reset_focus: bool = false):
	var current_items = []
	for item_id in player_stats.inventory.keys():
		var count = player_stats.inventory[item_id]
		if count > 0:
			var item_data = ItemDB.get_item(item_id)
			current_items.append({"id": item_id, "data": item_data, "count": count})
			
	current_items.sort_custom(func(a, b): return a.data.type > b.data.type)

	var current_skills = []
	if player_stats.skills:
		for skill in player_stats.skills:
			current_skills.append(skill)
			
	if reset_focus:
		tabbed_menu.set_data(current_items, current_skills)
		tabbed_menu.reset_focus(TabbedMenuView.TabSide.ITEMS, TabbedMenuView.FocusState.FOCUS_TABS)
	else:
		tabbed_menu.refresh_keep_state(current_items, current_skills)

func _on_item_selected(item_dict):
	_use_item(item_dict)

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
			_update_data_and_refresh(false)
			
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
			_update_data_and_refresh(false)

func _on_game_loaded():
	player_stats = EntityDB.get_stats("player")
	if visible:
		refresh()
