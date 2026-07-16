# res://ui/stat_info_view.gd
extends HBoxContainer

var player_stats: Stats

var name_lbl: RichTextLabel
var exp_lbl: RichTextLabel
var hp_lbl: RichTextLabel
var mp_lbl: RichTextLabel
var atk_lbl: RichTextLabel
var def_lbl: RichTextLabel
var spd_lbl: RichTextLabel

var equip_labels: Dictionary = {}

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	player_stats = EntityDB.get_stats("player")
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(hbox)
	
	# Left Side: Stats
	var stat_vbox = VBoxContainer.new()
	stat_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(stat_vbox)

	name_lbl = _create_label("")
	name_lbl.add_theme_color_override("default_color", ThemeConfig.COLOR_TEXT_HIGHLIGHT)
	stat_vbox.add_child(name_lbl)
	
	exp_lbl = _create_label("")
	stat_vbox.add_child(exp_lbl)
	
	hp_lbl = _create_label("")
	mp_lbl = _create_label("")
	atk_lbl = _create_label("")
	def_lbl = _create_label("")
	spd_lbl = _create_label("")

	stat_vbox.add_child(hp_lbl)
	stat_vbox.add_child(mp_lbl)
	stat_vbox.add_child(atk_lbl)
	stat_vbox.add_child(def_lbl)
	stat_vbox.add_child(spd_lbl)
	
	# Right Side: Equipment
	var equip_vbox = VBoxContainer.new()
	equip_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(equip_vbox)
	
	var equip_title = _create_label("EQUIPMENT")
	equip_title.add_theme_color_override("default_color", ThemeConfig.COLOR_TEXT_HIGHLIGHT)
	equip_vbox.add_child(equip_title)
	
	for slot in player_stats.equipment.keys():
		var lbl = _create_label("")
		equip_vbox.add_child(lbl)
		equip_labels[slot] = lbl

	_update_stats()

	EventBus.encounter_monster.connect(_on_encounter_monster)
	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.player_stats_changed.connect(_update_stats)
	EventBus.preview_item.connect(_on_preview_item)
	EventBus.clear_preview.connect(_on_clear_preview)

func _create_label(text: String) -> RichTextLabel:
	var lbl = RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.fit_content = true
	lbl.text = text
	return lbl

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
	name_lbl.text = player_stats.entity_name + " LV." + str(player_stats.level)
	exp_lbl.text = "EXP: " + str(player_stats.exp) + " / " + str(player_stats.max_exp)
	
	hp_lbl.text = "HP: " + str(player_stats.current_hp) + "/" + str(player_stats.get_total_max_hp())
	mp_lbl.text = "MP: " + str(player_stats.current_mp) + "/" + str(player_stats.get_total_max_mp())
	atk_lbl.text = "ATK: " + str(player_stats.get_total_atk())
	def_lbl.text = "DEF: " + str(player_stats.get_total_def())
	spd_lbl.text = "SPD: " + str(player_stats.get_total_spd())
	
	# Update equipment list
	for slot in equip_labels.keys():
		var item = player_stats.equipment[slot]
		var item_name = item.item_name if item else "NONE"
		equip_labels[slot].text = tr(_get_slot_name(slot)) + ": " + tr(item_name)
		equip_labels[slot].modulate = ThemeConfig.COLOR_TEXT_NORMAL # Reset highlight

func _on_preview_item(item_data: Resource):
	_update_stats() # Reset to base state first
	
	var stat_labels = {
		"hp": hp_lbl,
		"mp": mp_lbl,
		"atk": atk_lbl,
		"def": def_lbl,
		"spd": spd_lbl
	}
	
	var effects = item_data.get_effects()
	
	if item_data.type == Item.ItemType.EQUIPMENT:
		var slot = item_data.equip_slot
		if equip_labels.has(slot):
			equip_labels[slot].modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT # Highlight the slot being replaced
			
		var old_equip = player_stats.equipment[slot]
		var old_effects = old_equip.get_effects() if old_equip else {}
		
		# For equipment, we want to show the DELTA across all possible stats
		# To do this safely, we combine all keys from both new and old effects
		var all_keys = []
		for k in effects.keys():
			if not all_keys.has(k): all_keys.append(k)
		for k in old_effects.keys():
			if not all_keys.has(k): all_keys.append(k)
			
		for stat_name in all_keys:
			if not stat_labels.has(stat_name): continue
			
			var new_val = effects.get(stat_name, 0)
			var old_val = old_effects.get(stat_name, 0)
			var delta = new_val - old_val
			
			var lbl = stat_labels[stat_name]
			if delta > 0:
				lbl.text += " [color=green](+" + str(delta) + ")[/color]"
			elif delta < 0:
				lbl.text += " [color=red](" + str(delta) + ")[/color]"
				
	else:
		# Potion logic
		for stat_name in effects.keys():
			var val = effects[stat_name]
			var lbl = stat_labels[stat_name]
			
			if stat_name == "hp" or stat_name == "mp":
				var max_val = player_stats.get_total_max_hp() if stat_name == "hp" else player_stats.get_total_max_mp()
				var cur_val = player_stats.current_hp if stat_name == "hp" else player_stats.current_mp
				val = min(val, max_val - cur_val)
				if val <= 0: continue
				
			if val > 0:
				lbl.text += " [color=green](+" + str(val) + ")[/color]"
			elif val < 0:
				lbl.text += " [color=red](" + str(val) + ")[/color]"

func _on_clear_preview():
	_update_stats()

func _on_encounter_monster(_id: String, _node: Node):
	visible = false

func _on_battle_ended(_result: String):
	_update_stats()
	visible = true
