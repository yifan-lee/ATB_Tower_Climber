# res://ui/stat_info_view.gd
extends HBoxContainer

var player_stats: Stats

var hp_lbl: RichTextLabel
var mp_lbl: RichTextLabel
var atk_lbl: RichTextLabel
var def_lbl: RichTextLabel
var spd_lbl: RichTextLabel

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	player_stats = EntityDB.get_stats("player")
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(vbox)

	var name_lbl = _create_label(player_stats.entity_name)
	name_lbl.add_theme_color_override("default_color", Color(1, 1, 0))
	vbox.add_child(name_lbl)
	
	hp_lbl = _create_label("")
	mp_lbl = _create_label("")
	atk_lbl = _create_label("")
	def_lbl = _create_label("")
	spd_lbl = _create_label("")

	vbox.add_child(hp_lbl)
	vbox.add_child(mp_lbl)
	vbox.add_child(atk_lbl)
	vbox.add_child(def_lbl)
	vbox.add_child(spd_lbl)

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

func _update_stats():
	hp_lbl.text = "HP: " + str(player_stats.current_hp) + "/" + str(player_stats.max_hp)
	mp_lbl.text = "MP: " + str(player_stats.current_mp) + "/" + str(player_stats.max_mp)
	atk_lbl.text = "ATK: " + str(player_stats.atk)
	def_lbl.text = "DEF: " + str(player_stats.def)
	spd_lbl.text = "SPD: " + str(player_stats.spd)

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
	
	for stat_name in effects.keys():
		var val = effects[stat_name]
		var lbl = stat_labels[stat_name]
		
		# Limit potion healing to max capacity
		if item_data.type == Item.ItemType.POTION and (stat_name == "hp" or stat_name == "mp"):
			var max_val = player_stats.max_hp if stat_name == "hp" else player_stats.max_mp
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
