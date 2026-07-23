# res://config/item_db.gd
extends Node

var db: Dictionary = {}

func _ready():
	var hp_herb_lv1 = Item.new().setup(
		"hp_herb_lv1",
		"ITEM_HP_POTION_NAME",
		Item.ItemType.POTION,
		50, # 回血50
		0,
		"ITEM_HP_POTION_DESC"
	)
	hp_herb_lv1.icon = get_atlas_icon("res://assets/sprites/item/herb.png", 2, 6, 0, 0)
	db["hp_herb_lv1"] = hp_herb_lv1

	var hp_herb_lv2 = Item.new().setup(
		"hp_herb_lv2",
		"ITEM_HP_POTION_NAME",
		Item.ItemType.POTION,
		50, # 回血50
		0,
		"ITEM_HP_POTION_DESC"
	)
	hp_herb_lv2.icon = get_atlas_icon("res://assets/sprites/item/herb.png", 2, 6, 0, 1)
	db["hp_herb_lv2"] = hp_herb_lv2
	
	var mp_herb_lv1 = Item.new().setup(
		"mp_herb_lv1",
		"ITEM_MP_POTION_NAME",
		Item.ItemType.POTION,
		0,
		50, # 回蓝50
		"ITEM_MP_POTION_DESC"
	)
	mp_herb_lv1.icon = get_atlas_icon("res://assets/sprites/item/herb.png", 2, 6, 0, 3)
	db["mp_herb_lv1"] = mp_herb_lv1

	var helm_lv1 = Item.new().setup(
		"helm_lv1",
		"EQUIPMENT_HELM_LV1",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_HELM_LV1_DESC",
		0, 10, 0, Item.EquipSlot.HEAD
	)
	helm_lv1.icon = get_atlas_icon("res://assets/sprites/item/arm.png", 5, 5, 0, 0)
	db["helm_lv1"] = helm_lv1

	var chestplate_lv1 = Item.new().setup(
		"chestplate_lv1",
		"EQUIPMENT_HELM_LV1",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_HELM_LV1_DESC",
		0, 10, 0, Item.EquipSlot.HEAD
	)
	chestplate_lv1.icon = get_atlas_icon("res://assets/sprites/item/arm.png", 5, 5, 0, 1)
	db["chestplate_lv1"] = chestplate_lv1

	var leggings_lv1 = Item.new().setup(
		"leggings_lv1",
		"EQUIPMENT_HELM_LV1",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_HELM_LV1_DESC",
		0, 10, 0, Item.EquipSlot.HEAD
	)
	leggings_lv1.icon = get_atlas_icon("res://assets/sprites/item/arm.png", 5, 5, 0, 2)
	db["leggings_lv1"] = leggings_lv1

	var boot_lv1 = Item.new().setup(
		"boot_lv1",
		"EQUIPMENT_BOOTS_LV1",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BOOTS_LV1_DESC",
		0, 0, 10, Item.EquipSlot.FEET
	)
	boot_lv1.icon = get_atlas_icon("res://assets/sprites/item/arm.png", 5, 5, 0, 3)
	db["boot_lv1"] = boot_lv1

	var bracers_lv1 = Item.new().setup(
		"bracers_lv1",
		"EQUIPMENT_HELM_LV1",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_HELM_LV1_DESC",
		0, 10, 0, Item.EquipSlot.HEAD
	)
	bracers_lv1.icon = get_atlas_icon("res://assets/sprites/item/arm.png", 5, 5, 0, 4)
	db["bracers_lv1"] = bracers_lv1

	var sword_lv1 = Item.new().setup(
		"sword_lv1",
		"EQUIPMENT_SWORD_LV1",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_SWORD_LV1_DESC",
		20, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	sword_lv1.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 1, 1)
	db["sword_lv1"] = sword_lv1

	var tree_branch = Item.new().setup(
		"tree_branch",
		"EQUIPMENT_TREE_BRANCH",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_TREE_BRANCH_DESC",
		5, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	tree_branch.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 0, 1)
	db["tree_branch"] = tree_branch

	var sword_lv2 = Item.new().setup(
		"sword_lv2",
		"EQUIPMENT_JY_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_JY_SWORD_DESC",
		100, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	sword_lv2.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 2, 1)
	db["sword_lv2"] = sword_lv2

	var sword_lv5 = Item.new().setup(
		"sword_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	sword_lv5.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 4, 1)
	db["sword_lv5"] = sword_lv5

	var blade_lv1 = Item.new().setup(
		"swordblade_lv1_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	blade_lv1.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 0, 3)
	db["blade_lv1"] = blade_lv1

	var dagger_lv1 = Item.new().setup(
		"swordblade_lv1_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	dagger_lv1.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 0, 4)
	db["dagger_lv1"] = dagger_lv1

	var shield_lv1 = Item.new().setup(
		"swordblade_lv1_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	shield_lv1.icon = get_atlas_icon("res://assets/sprites/item/weapon2.png", 5, 5, 0, 0)
	db["shield_lv1"] = shield_lv1

	var spear_lv1 = Item.new().setup(
		"swordblade_lv1_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	spear_lv1.icon = get_atlas_icon("res://assets/sprites/item/weapon2.png", 5, 5, 0, 1)
	db["spear_lv1"] = spear_lv1

	var fan_lv1 = Item.new().setup(
		"swordblade_lv1_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	fan_lv1.icon = get_atlas_icon("res://assets/sprites/item/weapon2.png", 5, 5, 0, 3)
	db["fan_lv1"] = fan_lv1

	var staff_lv1 = Item.new().setup(
		"swordblade_lv1_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	staff_lv1.icon = get_atlas_icon("res://assets/sprites/item/weapon2.png", 5, 5, 0, 4)
	db["staff_lv1"] = staff_lv1
	
	
	var spirit_stone = Item.new().setup(
		"spirit_stone",
		"ITEM_SPIRIT_STONE_NAME",
		Item.ItemType.MATERIAL,
		0, 0, "ITEM_SPIRIT_STONE_DESC"
	)
	spirit_stone.icon = load("res://assets/sprites/item/gold.png")
	db["spirit_stone"] = spirit_stone
	
	var frag_red = Item.new().setup(
		"fragment_red",
		"ITEM_FRAG_RED_NAME",
		Item.ItemType.MATERIAL,
		0, 0, "ITEM_FRAG_RED_DESC"
	)
	frag_red.icon = get_atlas_icon("res://assets/sprites/item/fragment.png", 2, 2, 0, 0)
	db["fragment_red"] = frag_red

	var frag_yellow = Item.new().setup(
		"fragment_yellow",
		"ITEM_FRAG_YELLOW_NAME",
		Item.ItemType.MATERIAL,
		0, 0, "ITEM_FRAG_YELLOW_DESC"
	)
	frag_yellow.icon = get_atlas_icon("res://assets/sprites/item/fragment.png", 2, 2, 1, 0)
	db["fragment_yellow"] = frag_yellow

	var frag_blue = Item.new().setup(
		"fragment_blue",
		"ITEM_FRAG_BLUE_NAME",
		Item.ItemType.MATERIAL,
		0, 0, "ITEM_FRAG_BLUE_DESC"
	)
	frag_blue.icon = get_atlas_icon("res://assets/sprites/item/fragment.png", 2, 2, 0, 1)
	db["fragment_blue"] = frag_blue

	var frag_white = Item.new().setup(
		"fragment_white",
		"ITEM_FRAG_WHITE_NAME",
		Item.ItemType.MATERIAL,
		0, 0, "ITEM_FRAG_WHITE_DESC"
	)
	frag_white.icon = get_atlas_icon("res://assets/sprites/item/fragment.png", 2, 2, 1, 1)
	db["fragment_white"] = frag_white
	

func get_item(id: String) -> Item:
	if db.has(id):
		return db[id]
	else:
		push_error("找不到物品 ID: " + id)
		return null

var _texture_cache: Dictionary = {}

# 动态生成图集资源，不需要手动建 25 个 tres 文件！
# texture_path: 贴图路径 (例如 "res://assets/sprites/item/weapon1.png")
# cols: 这张图横向有几列 (5)
# rows: 这张图纵向有几行 (5)
# col_idx: 你要取的物品在第几列 (0 ~ 4)
# row_idx: 你要取的物品在第几行 (0 ~ 4)
func get_atlas_icon(texture_path: String, cols: int, rows: int, col_idx: int, row_idx: int) -> AtlasTexture:
	var base_tex: Texture2D = null
	if _texture_cache.has(texture_path):
		base_tex = _texture_cache[texture_path]
	else:
		base_tex = load(texture_path) as Texture2D
		if base_tex != null:
			_texture_cache[texture_path] = base_tex

	if not base_tex:
		push_error("找不到图集: " + texture_path)
		return null
		
	var atlas = AtlasTexture.new()
	atlas.atlas = base_tex
	
	var w = base_tex.get_width() / cols
	var h = base_tex.get_height() / rows
	
	atlas.region = Rect2(col_idx * w, row_idx * h, w, h)
	return atlas
