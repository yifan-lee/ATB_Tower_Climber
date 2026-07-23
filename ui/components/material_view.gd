# res://ui/components/material_view.gd
extends VBoxContainer
class_name MaterialView

func _ready():
	add_theme_constant_override("separation", 2)

func update_materials(inventory: Dictionary, expected_changes: Dictionary = {}):
	# Clear old labels
	for child in get_children():
		child.queue_free()
		
	# Find materials
	var has_materials = false
	for id in inventory:
		var qty = inventory[id]
		if qty > 0:
			var item = ItemDB.get_item(id)
			if item and item.type == Item.ItemType.MATERIAL:
				has_materials = true
				var label = UIUtils.create_rich_label()
				
				var text = "%s: %d" % [tr(item.item_name), qty]
				
				var delta = expected_changes.get(id, 0)
				if delta > 0:
					text += " [color=green](+" + str(delta) + ")[/color]"
				elif delta < 0:
					text += " [color=red](" + str(delta) + ")[/color]"
					
				label.text = text
				add_child(label)
	
	if has_materials:
		show()
	else:
		hide()
