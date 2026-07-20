extends PanelContainer

const SaveManager = preload("res://core/save_manager.gd")

var tabs_hbox: HBoxContainer
var save_tab_label: Label
var load_tab_label: Label
var content_vbox: VBoxContainer

var input_line: LineEdit
var item_list: ItemList
var confirm_btn: Button

enum TabSide {SAVE, LOAD}
var current_tab: TabSide = TabSide.SAVE

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
	
	# Tabs
	tabs_hbox = HBoxContainer.new()
	tabs_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_hbox.add_theme_constant_override("separation", 50)
	main_vbox.add_child(tabs_hbox)
	
	save_tab_label = Label.new()
	tabs_hbox.add_child(save_tab_label)
	
	load_tab_label = Label.new()
	tabs_hbox.add_child(load_tab_label)
	
	# Content area
	content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(content_vbox)
	
	input_line = LineEdit.new()
	input_line.custom_minimum_size = Vector2(300, 40)
	input_line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content_vbox.add_child(input_line)
	
	item_list = ItemList.new()
	item_list.custom_minimum_size = Vector2(300, 200)
	item_list.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content_vbox.add_child(item_list)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	content_vbox.add_child(spacer)
	
	confirm_btn = Button.new()
	confirm_btn.custom_minimum_size = Vector2(120, 40)
	confirm_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	confirm_btn.pressed.connect(_on_confirm)
	content_vbox.add_child(confirm_btn)
	
func refresh():
	current_tab = TabSide.SAVE
	_refresh_view()
	
func _refresh_view():
	if current_tab == TabSide.SAVE:
		save_tab_label.text = "> " + tr("SAVE GAME")
		save_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
		load_tab_label.text = "   " + tr("LOAD GAME")
		load_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		input_line.show()
		item_list.hide()
		var date_time = Time.get_datetime_string_from_system().replace("T", "_").replace(":", "-")
		input_line.text = "save_" + date_time
		confirm_btn.text = tr("SAVE")
	else:
		load_tab_label.text = "> " + tr("LOAD GAME")
		load_tab_label.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
		save_tab_label.text = "   " + tr("SAVE GAME")
		save_tab_label.modulate = ThemeConfig.COLOR_TEXT_DISABLED
		
		input_line.hide()
		item_list.show()
		item_list.clear()
		confirm_btn.text = tr("LOAD")
		
		var saves = SaveManager.get_save_files()
		for s in saves:
			item_list.add_item(s)
			
		if item_list.item_count > 0:
			item_list.select(0)

var input_cooldown: float = 0.0
const INPUT_DELAY: float = 0.15

func _process(delta: float):
	if not visible:
		return
		
	# Input line handling logic overrides GameConfig inputs if it has focus
	if input_line.has_focus():
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		_on_confirm()
		return
		
	if input_cooldown > 0:
		input_cooldown -= delta
		return
		
	var moved = false
	if GameConfig.is_pressing_left():
		if current_tab == TabSide.LOAD:
			current_tab = TabSide.SAVE
			_refresh_view()
			moved = true
	elif GameConfig.is_pressing_right():
		if current_tab == TabSide.SAVE:
			current_tab = TabSide.LOAD
			_refresh_view()
			moved = true
	elif current_tab == TabSide.LOAD:
		if GameConfig.is_pressing_up():
			var selected = item_list.get_selected_items()
			if selected.size() > 0 and selected[0] > 0:
				item_list.select(selected[0] - 1)
				moved = true
		elif GameConfig.is_pressing_down():
			var selected = item_list.get_selected_items()
			if selected.size() > 0 and selected[0] < item_list.item_count - 1:
				item_list.select(selected[0] + 1)
				moved = true
				
	if moved:
		input_cooldown = INPUT_DELAY

func _on_confirm():
	var main = get_tree().root.get_node("Main")
	if not main:
		return
		
	if current_tab == TabSide.SAVE:
		var s_name = input_line.text.strip_edges()
		if s_name != "":
			SaveManager.save_game(s_name, main)
			main.change_state(main.AppState.MAP)
	else:
		var selected = item_list.get_selected_items()
		if selected.size() > 0:
			var s_name = item_list.get_item_text(selected[0])
			SaveManager.load_game(s_name, main)
			main.change_state(main.AppState.MAP)
