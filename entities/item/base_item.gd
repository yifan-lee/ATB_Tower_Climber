# res://entities/item/base_item.gd
extends Area2D
class_name BaseItem

var sprite: Sprite2D
var item_id: String

func setup(id: String):
	item_id = id
	var item_data = ItemDB.get_item(item_id)
	if not item_data:
		push_error("Cannot find item in ItemDB: " + item_id)
		return
		
	sprite = Sprite2D.new()
	if item_data.icon:
		sprite.texture = item_data.icon
	else:
		sprite.texture = MapDB.get_fallback_texture()
		
	var orig_size = sprite.texture.get_size()
	sprite.scale = Vector2(GameConfig.GRID_SIZE / orig_size.x, GameConfig.GRID_SIZE / orig_size.y)
	add_child(sprite)

func _ready():
	add_to_group("item")
