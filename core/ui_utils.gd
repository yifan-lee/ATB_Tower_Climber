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
	var translated_name = TranslationServer.translate("STAT_" + stat_name.to_upper())
	var text = translated_name + ": " + str(current)
	if max_val >= 0:
		text += "/" + str(max_val)
		
	if delta > 0:
		text += " [color=green](+" + str(delta) + ")[/color]"
	elif delta < 0:
		text += " [color=red](" + str(delta) + ")[/color]"
		
	return text

static var _texture_cache = {}

static func _get_square_texture(color: Color, size: int = 16) -> ImageTexture:
	var key = str(color) + "_" + str(size)
	if _texture_cache.has(key):
		return _texture_cache[key]
		
	var image = Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.create_from_image(image)
	_texture_cache[key] = texture
	return texture

static func show_skill_list(container: Control, skills_info: Array, current_selection: int, desc_label = null, emit_preview: bool = false):
	for child in container.get_children():
		child.queue_free()
		
	for i in range(skills_info.size()):
		var info = skills_info[i]
		var skill = info.skill if typeof(info) == TYPE_DICTIONARY and info.has("skill") else info
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		
		# Radial CD Indicator
		var cd_bar = TextureProgressBar.new()
		cd_bar.texture_under = _get_square_texture(Color(0.2, 0.2, 0.2, 1.0))
		cd_bar.texture_progress = _get_square_texture(Color(1.0, 1.0, 1.0, 1.0))
		cd_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE
		cd_bar.min_value = 0
		cd_bar.max_value = max(0.01, skill.max_cd)
		cd_bar.value = max(0, skill.max_cd - skill.current_cd)
		cd_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cd_bar.set_meta("skill_obj", skill)
		cd_bar.set_meta("is_cd_bar", true)
		
		var lbl = Label.new()
		lbl.set_meta("skill_obj", skill)
		lbl.set_meta("is_skill_label", true)
		lbl.set_meta("is_selected", (i == current_selection))
		
		var prefix = "> " if i == current_selection else "   "
		var text_str = TranslationServer.translate(skill.skill_name)
		
		if skill.current_cd > 0:
			text_str += " (CD:" + str(ceil(skill.current_cd)) + ")"
			lbl.modulate = ThemeConfig.COLOR_TEXT_DISABLED
			cd_bar.modulate = Color(0.7, 0.7, 0.7, 1.0) # Dim the progress bar slightly when on CD
		elif i == current_selection:
			lbl.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			lbl.modulate = ThemeConfig.COLOR_TEXT_DISABLED
			
		lbl.text = prefix + text_str
		
		hbox.add_child(cd_bar)
		hbox.add_child(lbl)
		container.add_child(hbox)
		
		if i == current_selection and desc_label != null:
			var desc = TranslationServer.translate(skill.description) + "\n"
			desc += TranslationServer.translate("DISPLAY_DAMAGE") + str(skill.damage) + "\n"
			desc += TranslationServer.translate("DISPLAY_MANA_COST") + str(skill.mana_cost) + "\n"
			desc += TranslationServer.translate("DISPLAY_CD") + str(skill.max_cd)
			
			if desc_label is RichTextLabel:
				desc_label.text = "[color=yellow]" + TranslationServer.translate(skill.skill_name) + "[/color]\n" + desc
			else:
				desc_label.text = desc
				
			if emit_preview:
				var estimated_damage = info.estimated_damage if typeof(info) == TYPE_DICTIONARY and info.has("estimated_damage") else skill.damage
				EventBus.preview_skill.emit({
					"enemy_changes": {"hp": - estimated_damage},
					"player_changes": {"mp": - skill.mana_cost}
				})

static func update_skill_list_cooldowns(container: Control, skills_info: Array):
	for hbox in container.get_children():
		var cd_bar = null
		var lbl = null
		for child in hbox.get_children():
			if child.has_meta("is_cd_bar"): cd_bar = child
			elif child.has_meta("is_skill_label"): lbl = child
		
		if cd_bar != null and lbl != null:
			var skill = cd_bar.get_meta("skill_obj")
			var is_sel = lbl.get_meta("is_selected")
			
			cd_bar.value = max(0, skill.max_cd - skill.current_cd)
			
			var prefix = "> " if is_sel else "   "
			var text_str = TranslationServer.translate(skill.skill_name)
			if skill.current_cd > 0:
				text_str += " (CD:" + str(ceil(skill.current_cd)) + ")"
				lbl.modulate = ThemeConfig.COLOR_TEXT_DISABLED
				cd_bar.modulate = Color(0.7, 0.7, 0.7, 1.0)
			elif is_sel:
				lbl.modulate = ThemeConfig.COLOR_TEXT_NORMAL
				cd_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)
			else:
				lbl.modulate = ThemeConfig.COLOR_TEXT_DISABLED
				cd_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)
				
			lbl.text = prefix + text_str

static func get_inventory_categories() -> Array:
	return [Item.ItemType.POTION, Item.ItemType.EQUIPMENT, Item.ItemType.MATERIAL, Item.ItemType.KEY_ITEM]

static func get_category_names() -> Array:
	return ["TAB_POTIONS", "TAB_EQUIPMENT", "TAB_MATERIALS", "TAB_KEY_ITEMS"]

static func filter_items_by_category(items: Array, category: int) -> Array:
	var filtered = []
	for itm in items:
		if itm.data.type == category:
			filtered.append(itm)
	return filtered

static func show_inventory_list(container: Control, filtered_items: Array, current_category_idx: int, current_item_selection: int, is_category_focused: bool, desc_label = null, is_battle_mode: bool = false, emit_preview: bool = false):
	for child in container.get_children():
		child.queue_free()
		
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(hbox)
	
	# Categories List
	var cat_vbox = VBoxContainer.new()
	cat_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_vbox.size_flags_stretch_ratio = 0.5
	hbox.add_child(cat_vbox)
	
	var categories = get_inventory_categories()
	var category_names = get_category_names()
	
	for i in range(categories.size()):
		var lbl = Label.new()
		var prefix = "> " if (i == current_category_idx and is_category_focused) else "   "
		lbl.text = prefix + TranslationServer.translate(category_names[i])
		
		if is_category_focused and i == current_category_idx:
			lbl.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		elif not is_category_focused and i == current_category_idx:
			lbl.modulate = ThemeConfig.COLOR_TEXT_HIGHLIGHT
		else:
			lbl.modulate = ThemeConfig.COLOR_TEXT_DISABLED
			
		cat_vbox.add_child(lbl)
		
	# Items List
	var item_vbox = VBoxContainer.new()
	item_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(item_vbox)
	
	var item_previewed = false
	for i in range(filtered_items.size()):
		var itm = filtered_items[i]
		var item_data = itm.data
		var lbl = Label.new()
		
		var is_disabled = is_battle_mode and item_data.type != Item.ItemType.POTION
		var prefix = "> " if (i == current_item_selection and not is_disabled and not is_category_focused) else "   "
		
		if i == current_item_selection and is_disabled and not is_category_focused:
			prefix = "[x] "
			
		lbl.text = prefix + TranslationServer.translate(item_data.item_name) + " x" + str(itm.count)
		
		if is_disabled:
			lbl.modulate = Color(0.4, 0.4, 0.4, 1.0)
		elif i == current_item_selection and not is_category_focused:
			lbl.modulate = ThemeConfig.COLOR_TEXT_NORMAL
		else:
			lbl.modulate = ThemeConfig.COLOR_TEXT_DISABLED
			
		item_vbox.add_child(lbl)
		
		if i == current_item_selection and not is_category_focused and desc_label != null:
			if desc_label is RichTextLabel:
				desc_label.text = "[color=yellow]" + TranslationServer.translate(item_data.item_name) + "[/color]\n" + TranslationServer.translate(item_data.description)
			else:
				desc_label.text = TranslationServer.translate(item_data.description)
				
			if emit_preview:
				EventBus.preview_item.emit(item_data)
			item_previewed = true

	if not item_previewed and emit_preview:
		EventBus.clear_preview.emit()
