# res://config/item_db.gd
extends Node

var db: Dictionary = {}

func _ready():
	var hp_potion = Item.new().setup(
		"hp_potion",
		"ITEM_HP_POTION_NAME",
		Item.ItemType.POTION,
		50, # 回血50
		0,
		"ITEM_HP_POTION_DESC"
	)
	hp_potion.icon = load("res://assets/sprites/item/HealthPotion.png")
	db["hp_potion"] = hp_potion
	
	var mp_potion = Item.new().setup(
		"mp_potion",
		"ITEM_MP_POTION_NAME",
		Item.ItemType.POTION,
		0,
		50, # 回蓝50
		"ITEM_MP_POTION_DESC"
	)
	mp_potion.icon = load("res://assets/sprites/item/ManaPotion.png")
	db["mp_potion"] = mp_potion

	var iron_helm = Item.new().setup(
		"iron_helm",
		"EQUIPMENT_IRON_HELM",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_IRON_HELM_DESC",
		0, 10, 0, Item.EquipSlot.HEAD
	)
	iron_helm.icon = load("res://assets/sprites/item/Helmet.png")
	db["iron_helm"] = iron_helm

	var iron_sword = Item.new().setup(
		"iron_sword",
		"EQUIPMENT_IRON_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_IRON_SWORD_DESC",
		10, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	iron_sword.icon = load("res://assets/sprites/item/Sword.png")
	db["iron_sword"] = iron_sword

	var tree_branch = Item.new().setup(
		"tree_branch",
		"EQUIPMENT_TREE_BRANCH",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_TREE_BRANCH_DESC",
		1, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	# tree_branch.icon = load(...)
	db["tree_branch"] = tree_branch

	var jy_sword = Item.new().setup(
		"jy_sword",
		"EQUIPMENT_JY_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_JY_SWORD_DESC",
		100, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	jy_sword.icon = load("res://assets/sprites/item/Sword.png")
	db["jy_sword"] = jy_sword
	
	var swift_boots = Item.new().setup(
		"swift_boots",
		"EQUIPMENT_SWIFT_BOOTS",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_SWIFT_BOOTS_DESC",
		0, 0, 10, Item.EquipSlot.FEET
	)
	swift_boots.icon = load("res://assets/sprites/item/LeatherBoot.png")
	db["swift_boots"] = swift_boots
	

func get_item(id: String) -> Item:
	if db.has(id):
		return db[id]
	else:
		push_error("找不到物品 ID: " + id)
		return null
