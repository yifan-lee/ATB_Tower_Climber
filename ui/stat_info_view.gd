# res://ui/stat_info_view.gd
extends PanelContainer

var player_stats: Stats

var entity_stat_view: EntityStatView
var equip_labels: Dictionary = {}

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = ThemeConfig.COLOR_UI_BG_SOLID
	add_theme_stylebox_override("panel", style)
	
	player_stats = EntityDB.get_stats("player")
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(hbox)
	
	# Left Side: Stats
	entity_stat_view = EntityStatView.new()
	hbox.add_child(entity_stat_view)
	
	# Right Side: Equipment
	var equip_vbox = VBoxContainer.new()
	equip_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(equip_vbox)
	
	var equip_title = UIUtils.create_rich_label("EQUIPMENT")
	equip_title.add_theme_color_override("default_color", ThemeConfig.COLOR_TEXT_HIGHLIGHT)
	equip_vbox.add_child(equip_title)
	
	for slot in player_stats.equipment.keys():
		var lbl = UIUtils.create_rich_label("")
		equip_vbox.add_child(lbl)
		equip_labels[slot] = lbl

	_update_stats()

	EventBus.encounter_monster.connect(_on_encounter_monster)
	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.player_stats_changed.connect(_update_stats)
	EventBus.preview_item.connect(_on_preview_item)
	EventBus.clear_preview.connect(_on_clear_preview)
	EventBus.game_loaded.connect(_on_game_loaded)

func _get_slot_name(slot: Item.EquipSlot) -> String:
	match slot:
		Item.EquipSlot.HEAD: return tr("SLOT_HEAD")
		Item.EquipSlot.CHEST: return tr("SLOT_CHEST")
		Item.EquipSlot.LEGS: return tr("SLOT_LEGS")
		Item.EquipSlot.FEET: return tr("SLOT_FEET")
		Item.EquipSlot.LEFT_HAND: return tr("SLOT_LEFT_HAND")
		Item.EquipSlot.RIGHT_HAND: return tr("SLOT_RIGHT_HAND")
		Item.EquipSlot.ACCESSORY: return tr("SLOT_ACCESSORY")
	return "UNKNOWN"

func _update_stats():
	entity_stat_view.update_stats(player_stats, {}, true)
	
	# Update equipment list
	for slot in equip_labels.keys():
		var item = player_stats.equipment[slot]
		var item_name = item.item_name if item else "NONE"
		equip_labels[slot].text = tr(_get_slot_name(slot)) + ": " + tr(item_name)
		equip_labels[slot].modulate = ThemeConfig.COLOR_TEXT_NORMAL # Reset highlight

func _on_preview_item(item_data: Resource):
	var expected_changes = {}
	var effects = item_data.get_effects()
	
	if item_data.type == Item.ItemType.EQUIPMENT:
		var slot = item_data.equip_slot
		if equip_labels.has(slot):
			equip_labels[slot].modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT # Highlight the slot being replaced
			
		var old_equip = player_stats.equipment[slot]
		var old_effects = old_equip.get_effects() if old_equip else {}
		
		# For equipment, we want to show the DELTA across all possible stats
		var all_keys = []
		for k in effects.keys():
			if not all_keys.has(k): all_keys.append(k)
		for k in old_effects.keys():
			if not all_keys.has(k): all_keys.append(k)
			
		for stat_name in all_keys:
			var new_val = effects.get(stat_name, 0)
			var old_val = old_effects.get(stat_name, 0)
			expected_changes[stat_name] = new_val - old_val
	else:
		# Potion logic
		expected_changes = effects.duplicate()
		
	entity_stat_view.update_stats(player_stats, expected_changes, true)

func _on_clear_preview():
	_update_stats()

func _on_encounter_monster(_id: String, _node: Node):
	visible = false

func _on_battle_ended(_result: String):
	_update_stats()
	visible = true

func _on_game_loaded():
	player_stats = EntityDB.get_stats("player")
	if visible:
		_update_stats()
