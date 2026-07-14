# res://data/item.gd
extends Resource
class_name Item

enum ItemType {
	POTION,
	EQUIPMENT
}

@export var item_id: String
@export var item_name: String
@export var type: ItemType
@export var effect_hp: int = 0
@export var effect_mp: int = 0
@export var description: String

func setup(id: String, n: String, t: ItemType, hp: int, mp: int, desc: String) -> Item:
	item_id = id
	item_name = n
	type = t
	effect_hp = hp
	effect_mp = mp
	description = desc
	return self
