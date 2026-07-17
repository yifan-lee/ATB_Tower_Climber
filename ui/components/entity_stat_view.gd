# res://ui/components/entity_stat_view.gd
extends VBoxContainer
class_name EntityStatView

var name_lbl: RichTextLabel
var exp_lbl: RichTextLabel
var stat_labels: Dictionary = {}

func _init():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	name_lbl = UIUtils.create_rich_label("")
	name_lbl.add_theme_color_override("default_color", ThemeConfig.COLOR_TEXT_HIGHLIGHT)
	add_child(name_lbl)
	
	exp_lbl = UIUtils.create_rich_label("")
	add_child(exp_lbl)
	
	# Pre-create standard labels
	var standard_stats = ["hp", "mp", "atk", "def", "spd"]
	for stat in standard_stats:
		var lbl = UIUtils.create_rich_label("")
		add_child(lbl)
		stat_labels[stat] = lbl

func update_stats(stats: Stats, expected_changes: Dictionary = {}, show_exp: bool = false):
	# Update Name and Level
	name_lbl.text = stats.entity_name + " LV." + str(stats.level)
	
	# Update EXP
	if show_exp:
		exp_lbl.text = "EXP: " + str(stats.exp) + " / " + str(stats.max_exp)
		exp_lbl.visible = true
	else:
		exp_lbl.visible = false
		
	# Ensure all standard and dynamically requested stat labels exist
	var all_stats = stat_labels.keys()
	for key in expected_changes.keys():
		if not all_stats.has(key):
			all_stats.append(key)
			
	for stat in all_stats:
		if not stat_labels.has(stat):
			var lbl = UIUtils.create_rich_label("")
			add_child(lbl)
			stat_labels[stat] = lbl
			
	# Update each stat label
	for stat in stat_labels.keys():
		var lbl = stat_labels[stat]
		var current = 0
		var max_val = -1
		var delta = expected_changes.get(stat, 0)
		
		# For HP and MP, the value in `expected_changes` (if it's a potion, for example) 
		# might be the change to `current_hp`. We apply min/max logic before formatting.
		if stat == "hp":
			current = stats.current_hp
			max_val = stats.get_total_max_hp()
			# If we are healing, we cap the delta to the missing health.
			# Note: If it's max_hp increasing from an item, that might be tracked as "max_hp" key, 
			# but usually we just show it if delta is explicitly set.
			if delta > 0:
				delta = min(delta, max_val - current)
		elif stat == "mp":
			current = stats.current_mp
			max_val = stats.get_total_max_mp()
			if delta > 0:
				delta = min(delta, max_val - current)
		elif stat == "atk":
			current = stats.get_total_atk()
		elif stat == "def":
			current = stats.get_total_def()
		elif stat == "spd":
			current = stats.get_total_spd()
		elif stat == "max_hp":
			# For equipment that changes max HP
			current = stats.get_total_max_hp()
		elif stat == "max_mp":
			current = stats.get_total_max_mp()
		else:
			# For custom or unknown stats
			current = 0 # Assume 0 if not explicitly defined in Stats class, or get it dynamically if we add properties
			
		lbl.text = UIUtils.format_stat(stat, current, max_val, delta)
