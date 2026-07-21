# res://config/item_db.gd
extends Node

var db: Dictionary = {}

func _ready():
	var hp_herb = Item.new().setup(
		"hp_herb",
		"ITEM_HP_POTION_NAME",
		Item.ItemType.POTION,
		50, # 回血50
		0,
		"ITEM_HP_POTION_DESC"
	)
	hp_herb.icon = get_atlas_icon("res://assets/sprites/item/herb.png", 2, 6, 0, 0)
	db["hp_herb"] = hp_herb
	
	var mp_herb = Item.new().setup(
		"mp_herb",
		"ITEM_MP_POTION_NAME",
		Item.ItemType.POTION,
		0,
		50, # 回蓝50
		"ITEM_MP_POTION_DESC"
	)
	mp_herb.icon = get_atlas_icon("res://assets/sprites/item/herb.png", 2, 6, 3, 0)
	db["mp_herb"] = mp_herb

	var iron_helm = Item.new().setup(
		"iron_helm",
		"EQUIPMENT_IRON_HELM",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_IRON_HELM_DESC",
		0, 10, 0, Item.EquipSlot.HEAD
	)
	iron_helm.icon = get_atlas_icon("res://assets/sprites/item/arm.png", 5, 5, 0, 0)
	db["iron_helm"] = iron_helm

	var sword_level1 = Item.new().setup(
		"sword_level1",
		"EQUIPMENT_IRON_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_IRON_SWORD_DESC",
		20, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	sword_level1.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 1, 1)
	db["sword_level1"] = sword_level1

	var tree_branch = Item.new().setup(
		"tree_branch",
		"EQUIPMENT_TREE_BRANCH",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_TREE_BRANCH_DESC",
		5, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	tree_branch.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 0, 1)
	db["tree_branch"] = tree_branch

	var sword_level2 = Item.new().setup(
		"sword_level2",
		"EQUIPMENT_JY_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_JY_SWORD_DESC",
		100, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	sword_level2.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 2, 1)
	db["sword_level2"] = sword_level2

	var sword_level5 = Item.new().setup(
		"sword_level5",
		"EQUIPMENT_BEST_SWORD",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BEST_SWORD_DESC",
		10000, 0, 0, Item.EquipSlot.RIGHT_HAND
	)
	sword_level5.icon = get_atlas_icon("res://assets/sprites/item/weapon1.png", 5, 5, 4, 1)
	db["sword_level5"] = sword_level5
	
	var boot_level1 = Item.new().setup(
		"boot_level1",
		"EQUIPMENT_BOOTS_LV1",
		Item.ItemType.EQUIPMENT,
		0, 0, "EQUIPMENT_BOOTS_LV1_DESC",
		0, 0, 10, Item.EquipSlot.FEET
	)
	boot_level1.icon = get_atlas_icon("res://assets/sprites/item/arm.png", 5, 5, 0, 3)
	db["boot_level1"] = boot_level1
	

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
