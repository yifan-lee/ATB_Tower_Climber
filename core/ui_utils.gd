# res://core/ui_utils.gd
class_name UIUtils
extends RefCounted

static func create_rich_label(text: String = "") -> RichTextLabel:
	var lbl = RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.fit_content = true
	lbl.text = text
	return lbl

static func format_stat(stat_name: String, current: int, max_val: int = -1, delta: int = 0) -> String:
	var text = stat_name.to_upper() + ": " + str(current)
	if max_val >= 0:
		text += "/" + str(max_val)
		
	if delta > 0:
		text += " [color=green](+" + str(delta) + ")[/color]"
	elif delta < 0:
		text += " [color=red](" + str(delta) + ")[/color]"
		
	return text
