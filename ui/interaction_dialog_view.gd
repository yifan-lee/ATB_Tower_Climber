# res://ui/interaction_dialog_view.gd
extends Control
class_name InteractionDialogView

var title_label: Label
var options_container: VBoxContainer
var option_labels: Array[Label] = []
var current_selection_index: int = 0

var current_options: Array = []

func _init():
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _ready():
	# Semi-transparent background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7) # Slightly transparent to see the game
	add_child(bg)
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = ThemeConfig.COLOR_UI_BG_SOLID
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = ThemeConfig.COLOR_TEXT_NORMAL
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	center_container.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)
	
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	options_container = VBoxContainer.new()
	options_container.add_theme_constant_override("separation", 10)
	vbox.add_child(options_container)

func setup(title: String, options: Array):
	title_label.text = title
	current_options = options
	
	# Clean old options
	for child in options_container.get_children():
		child.queue_free()
	option_labels.clear()
	
	var first_enabled = -1
	for i in range(options.size()):
		var opt = options[i]
		var text = opt.get("text", "")
		var enabled = opt.get("enabled", true)
		_add_option(text, enabled)
		if enabled and first_enabled == -1:
			first_enabled = i
	
	# Try to maintain selection index if possible
	if current_selection_index >= options.size() or not options[current_selection_index].get("enabled", true):
		current_selection_index = max(0, first_enabled)
	
	_update_selection_visual()

func _add_option(text: String, enabled: bool):
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	if not enabled:
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	options_container.add_child(lbl)
	option_labels.append(lbl)

func _update_selection_visual():
	for i in range(option_labels.size()):
		var opt = current_options[i]
		var is_enabled = opt.get("enabled", true)
		
		if i == current_selection_index:
			option_labels[i].text = "> " + option_labels[i].text.trim_prefix("> ")
			option_labels[i].add_theme_color_override("font_color", ThemeConfig.COLOR_TEXT_HIGHLIGHT)
		else:
			option_labels[i].text = option_labels[i].text.trim_prefix("> ")
			if is_enabled:
				option_labels[i].add_theme_color_override("font_color", ThemeConfig.COLOR_TEXT_NORMAL)
			else:
				option_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func _unhandled_input(event):
	if not visible:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_UP or event.keycode == KEY_W:
			_move_selection(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN or event.keycode == KEY_S:
			_move_selection(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			var opt = current_options[current_selection_index]
			if opt.get("enabled", true):
				if opt.get("close_on_select", true):
					EventBus.interaction_dialog_closed.emit()
				EventBus.interaction_action_selected.emit(opt.get("action", ""), opt.get("metadata", {}))
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE or event.keycode == KEY_X:
			EventBus.interaction_dialog_closed.emit()
			get_viewport().set_input_as_handled()

func _move_selection(dir: int):
	var start_idx = current_selection_index
	var size = option_labels.size()
	if size == 0:
		return
	
	var i = start_idx
	while true:
		i += dir
		if i < 0:
			i = size - 1
		elif i >= size:
			i = 0
			
		if i == start_idx:
			break
			
		if current_options[i].get("enabled", true):
			current_selection_index = i
			break
			
	_update_selection_visual()
