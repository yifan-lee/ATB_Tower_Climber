# res://ui/inventory_view.gd
extends PanelContainer

var player_stats: Stats
var category_list_box: VBoxContainer
var item_list_box: VBoxContainer
var desc_label: RichTextLabel
var hbox: HBoxContainer

enum FocusSide {CATEGORY, ITEMS}
var current_focus: FocusSide = FocusSide.CATEGORY
var category_index: int = 0
var item_index: int = 0

var categories = ["CATEGORY_POTION", "CATEGORY_EQUIP"]
var category_labels = []

var current_items = []
var item_labels = []

func _ready():
	visible = false
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.95)
	add_theme_stylebox_override("panel", style)
	
	# Create an HBoxContainer for layout
	hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(hbox)
	
	player_stats = EntityDB.get_stats("player")
	
	# Left panel
	var left_panel = VBoxContainer.new()
	left_panel.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(left_panel)
	
	left_panel.add_child(_create_title("CATEGORY_TITLE"))
	category_list_box = VBoxContainer.new()
	left_panel.add_child(category_list_box)
	
	# Right panel
	var right_panel = VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right_panel)
	
	right_panel.add_child(_create_title("ITEM_TITLE"))
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_child(scroll)
	
	item_list_box = VBoxContainer.new()
	scroll.add_child(item_list_box)
	
	# Description Box
	desc_label = RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.custom_minimum_size = Vector2(0, 80)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_child(desc_label)
	
	EventBus.show_inventory.connect(_on_show_inventory)
	EventBus.hide_inventory.connect(_on_hide_inventory)

func _create_title(text: String) -> Label:
	var lbl = Label.new()
	lbl.text = tr(text)
	lbl.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow title
	return lbl

func _on_show_inventory():
	visible = true
	current_focus = FocusSide.CATEGORY
	category_index = 0
	item_index = 0
	_refresh_categories()
	_refresh_items()

func _on_hide_inventory():
	visible = false
	EventBus.clear_preview.emit()

func _refresh_categories():
	for child in category_list_box.get_children():
		child.queue_free()
	category_labels.clear()
	
	for i in range(categories.size()):
		var lbl = Label.new()
		lbl.text = "   " + tr(categories[i])
		category_list_box.add_child(lbl)
		category_labels.append(lbl)
		
	_update_cursors()

func _refresh_items():
	for child in item_list_box.get_children():
		child.queue_free()
	item_labels.clear()
	current_items.clear()
	
	# Filter items by category
	var target_type = Item.ItemType.POTION if categories[category_index] == "CATEGORY_POTION" else Item.ItemType.EQUIPMENT
	
	for item_id in player_stats.inventory.keys():
		var count = player_stats.inventory[item_id]
		if count > 0:
			var item_data = ItemDB.get_item(item_id)
			if item_data.type == target_type:
				current_items.append({"id": item_id, "data": item_data, "count": count})
				
	for i in range(current_items.size()):
		var lbl = Label.new()
		var itm = current_items[i]
		lbl.text = "   " + tr(itm.data.item_name) + " x" + str(itm.count)
		item_list_box.add_child(lbl)
		item_labels.append(lbl)

	# Safety check
	if item_index >= current_items.size():
		item_index = max(0, current_items.size() - 1)
		
	if current_items.size() == 0 and current_focus == FocusSide.ITEMS:
		current_focus = FocusSide.CATEGORY
		
	_update_cursors()

func _update_cursors():
	# Update category labels
	for i in range(category_labels.size()):
		category_labels[i].text = category_labels[i].text.trim_prefix("   ").trim_prefix("> ")
		if i == category_index:
			if current_focus == FocusSide.CATEGORY:
				category_labels[i].text = "> " + category_labels[i].text
				category_labels[i].modulate = Color(1, 1, 1)
			else:
				category_labels[i].text = "   " + category_labels[i].text
				category_labels[i].modulate = Color(0.6, 0.6, 0.6)
		else:
			category_labels[i].text = "   " + category_labels[i].text
			category_labels[i].modulate = Color(0.6, 0.6, 0.6)
			
	# Update item labels and description
	desc_label.text = ""
	var item_previewed = false
	for i in range(item_labels.size()):
		item_labels[i].text = item_labels[i].text.trim_prefix("   ").trim_prefix("> ")
		if i == item_index and current_focus == FocusSide.ITEMS:
			item_labels[i].text = "> " + item_labels[i].text
			item_labels[i].modulate = Color(1, 1, 1)
			
			var itm_data = current_items[i].data
			desc_label.text = "[color=yellow]" + tr(itm_data.item_name) + "[/color]\n" + tr(itm_data.description)
			EventBus.preview_item.emit(itm_data)
			item_previewed = true
		else:
			item_labels[i].text = "   " + item_labels[i].text
			item_labels[i].modulate = Color(0.6, 0.6, 0.6)

	if not item_previewed:
		EventBus.clear_preview.emit()

func _input(event):
	if not visible:
		return
		
	if event.is_action_pressed("ui_up"):
		if current_focus == FocusSide.CATEGORY:
			category_index = max(0, category_index - 1)
			_refresh_items()
		else:
			item_index = max(0, item_index - 1)
			_update_cursors()
	elif event.is_action_pressed("ui_down"):
		if current_focus == FocusSide.CATEGORY:
			category_index = min(categories.size() - 1, category_index + 1)
			_refresh_items()
		else:
			item_index = min(current_items.size() - 1, item_index + 1)
			_update_cursors()
	elif event.is_action_pressed("ui_right"):
		if current_focus == FocusSide.CATEGORY and current_items.size() > 0:
			current_focus = FocusSide.ITEMS
			item_index = 0
			_update_cursors()
	elif event.is_action_pressed("ui_left"):
		if current_focus == FocusSide.ITEMS:
			current_focus = FocusSide.CATEGORY
			_update_cursors()
	elif event.is_action_pressed("ui_accept"):
		if current_focus == FocusSide.ITEMS and current_items.size() > 0:
			_use_item(current_items[item_index])

func _use_item(item_dict):
	var id = item_dict.id
	var item_data = item_dict.data
	
	if item_data.type == Item.ItemType.POTION:
		if player_stats.inventory[id] > 0:
			player_stats.inventory[id] -= 1
			player_stats.current_hp = min(player_stats.max_hp, player_stats.current_hp + item_data.effect_hp)
			player_stats.current_mp = min(player_stats.max_mp, player_stats.current_mp + item_data.effect_mp)
			EventBus.show_system_message.emit(["MSG_USED_ITEM", item_data.item_name])
			EventBus.player_stats_changed.emit()
			_refresh_items()
