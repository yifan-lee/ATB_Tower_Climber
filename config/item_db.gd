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

	db["iron_helm"] = Item.new().setup(
		"iron_helm",
		"EQUIPMENT_IRON_HELM",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_IRON_HELM_DESC",
		0, 10, 0, Item.EquipSlot.HEAD
	)

	db["iron_sword"] = Item.new().setup(
		"iron_sword",
		"EQUIPMENT_IRON_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_IRON_SWORD_DESC",
		10, 0, 0, Item.EquipSlot.RIGHT_HAND
	)

	db["tree_branch"] = Item.new().setup(
		"tree_branch",
		"EQUIPMENT_TREE_BRANCH",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_TREE_BRANCH_DESC",
		1, 0, 0, Item.EquipSlot.RIGHT_HAND
	)

	db["jy_sword"] = Item.new().setup(
		"jy_sword",
		"EQUIPMENT_JY_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_JY_SWORD_DESC",
		100, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	

func get_item(id: String) -> Item:
	if db.has(id):
		return db[id]
	else:
		push_error("找不到物品 ID: " + id)
		return null
