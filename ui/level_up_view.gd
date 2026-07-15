# res://ui/level_up_view.gd
extends Control

var player_stats: Stats
var available_points: int = 0

var temp_allocations: Dictionary = {
	"hp": 0,
	"mp": 0,
	"atk": 0,
	"def": 0,
	"spd": 0
}

# UI nodes
var points_label: Label
var hp_label: Label
var mp_label: Label
var atk_label: Label
var def_label: Label
var spd_label: Label
var confirm_label: Label

var current_selection_index: int = 0
const MAX_SELECTION_INDEX = 5 # 0:hp, 1:mp, 2:atk, 3:def, 4:spd, 5:confirm

func _ready():
	visible = false
	player_stats = EntityDB.get_stats("player")
	
	# Semi-transparent background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	vbox.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.GAME_AREA_HEIGHT - 100)
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var title = Label.new()
	title.text = "=== LEVEL UP ===" # Will be updated/translated if needed
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(title)
	
	points_label = Label.new()
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(points_label)
	
	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	hp_label = _create_stat_row(vbox)
	mp_label = _create_stat_row(vbox)
	atk_label = _create_stat_row(vbox)
	def_label = _create_stat_row(vbox)
	spd_label = _create_stat_row(vbox)
	
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer2)
	
	confirm_label = Label.new()
	confirm_label.text = "[ CONFIRM ]"
	confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(confirm_label)

	EventBus.show_level_up.connect(_on_show)
	EventBus.hide_level_up.connect(_on_hide)
	
	set_process_input(false)

func _create_stat_row(parent: Node) -> Label:
	var lbl = Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(lbl)
	return lbl

func _on_show():
	visible = true
	set_process_input(true)
	available_points = player_stats.stat_points
	current_selection_index = 0
	
	temp_allocations = {
		"hp": 0,
		"mp": 0,
		"atk": 0,
		"def": 0,
		"spd": 0
	}
	
	_update_ui()

func _on_hide():
	visible = false
	set_process_input(false)

func _update_ui():
	points_label.text = "Stat Points: " + str(available_points)
	
	_update_row(hp_label, 0, "HP", player_stats.max_hp, temp_allocations["hp"], 10)
	_update_row(mp_label, 1, "MP", player_stats.max_mp, temp_allocations["mp"], 5)
	_update_row(atk_label, 2, "ATK", player_stats.atk, temp_allocations["atk"], 1)
	_update_row(def_label, 3, "DEF", player_stats.def, temp_allocations["def"], 1)
	_update_row(spd_label, 4, "SPD", player_stats.spd, temp_allocations["spd"], 1)
	
	if current_selection_index == 5:
		if available_points == 0:
			confirm_label.add_theme_color_override("font_color", Color.YELLOW)
			confirm_label.text = "> [ CONFIRM ] <"
		else:
			confirm_label.add_theme_color_override("font_color", Color.DARK_GRAY)
			confirm_label.text = "  [ CONFIRM ]  "
	else:
		if available_points == 0:
			confirm_label.add_theme_color_override("font_color", Color.WHITE)
		else:
			confirm_label.add_theme_color_override("font_color", Color.DARK_GRAY)
		confirm_label.text = "  [ CONFIRM ]  "

func _update_row(lbl: Label, index: int, stat_name: String, base_val: int, allocated_pts: int, multiplier: int):
	var prefix = "> " if current_selection_index == index else "  "
	var suffix = " <" if current_selection_index == index else "  "
	
	var current_total = base_val + (allocated_pts * multiplier)
	var alloc_str = ""
	if allocated_pts > 0:
		alloc_str = " (+" + str(allocated_pts * multiplier) + ")"
		
	lbl.text = prefix + stat_name + ": " + str(current_total) + alloc_str + suffix
	if current_selection_index == index:
		lbl.add_theme_color_override("font_color", Color.YELLOW)
	else:
		lbl.add_theme_color_override("font_color", Color.WHITE)

func _input(event):
	if not visible:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_UP:
			current_selection_index = max(0, current_selection_index - 1)
			_update_ui()
			accept_event()
		elif event.keycode == KEY_DOWN:
			current_selection_index = min(MAX_SELECTION_INDEX, current_selection_index + 1)
			_update_ui()
			accept_event()
		elif event.keycode == KEY_LEFT:
			_handle_allocation(-1)
			accept_event()
		elif event.keycode == KEY_RIGHT:
			_handle_allocation(1)
			accept_event()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_Z:
			if current_selection_index == MAX_SELECTION_INDEX and available_points == 0:
				_apply_allocations()
				EventBus.hide_level_up.emit()
				accept_event()

func _handle_allocation(delta: int):
	var key = ""
	if current_selection_index == 0: key = "hp"
	elif current_selection_index == 1: key = "mp"
	elif current_selection_index == 2: key = "atk"
	elif current_selection_index == 3: key = "def"
	elif current_selection_index == 4: key = "spd"
	else: return
	
	if delta > 0 and available_points > 0:
		temp_allocations[key] += 1
		available_points -= 1
	elif delta < 0 and temp_allocations[key] > 0:
		temp_allocations[key] -= 1
		available_points += 1
		
	_update_ui()

func _apply_allocations():
	player_stats.max_hp += temp_allocations["hp"] * 10
	player_stats.current_hp += temp_allocations["hp"] * 10 # Also heal by the amount gained
	player_stats.max_mp += temp_allocations["mp"] * 5
	player_stats.current_mp += temp_allocations["mp"] * 5
	player_stats.atk += temp_allocations["atk"]
	player_stats.def += temp_allocations["def"]
	player_stats.spd += temp_allocations["spd"]
	
	player_stats.stat_points = 0 # Safety
	EventBus.player_stats_changed.emit()
