# res://config/item_db.gd
extends Node

var db: Dictionary = {}

func _ready():
	db["hp_potion"] = Item.new().setup(
		"hp_potion",
		"ITEM_HP_POTION_NAME",
		Item.ItemType.POTION,
		50, # 回血50
		0,
		"ITEM_HP_POTION_DESC"
	)
	
	db["mp_potion"] = Item.new().setup(
		"mp_potion",
		"ITEM_MP_POTION_NAME",
		Item.ItemType.POTION,
		0,
		50, # 回蓝50
		"ITEM_MP_POTION_DESC"
	)

func get_item(id: String) -> Item:
	if db.has(id):
		return db[id]
	else:
		push_error("找不到物品 ID: " + id)
		return null
