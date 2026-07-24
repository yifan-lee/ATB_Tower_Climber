# res://data/item.gd
extends Resource
class_name Item

enum ItemType {POTION, EQUIPMENT, MATERIAL, KEY_ITEM}
enum EquipSlot {NONE, HEAD, CHEST, LEGS, FEET, ARMS, LEFT_HAND, RIGHT_HAND, ACCESSORY}

@export var item_id: String
@export var item_name: String
@export var type: ItemType
@export var equip_slot: EquipSlot = EquipSlot.NONE
@export var effect_hp: int = 0
@export var effect_mp: int = 0
@export var effect_atk: int = 0
@export var effect_def: int = 0
@export var effect_spd: int = 0
@export var description: String
@export var icon: Texture2D

func setup(
	id: String, n: String, t: ItemType, desc: String,
	slot: EquipSlot = EquipSlot.NONE,
	hp: int = 0, mp: int = 0, atk: int = 0, def: int = 0, spd: int = 0
) -> Item:
	item_id = id
	item_name = n
	type = t
	effect_hp = hp
	effect_mp = mp
	effect_atk = atk
	effect_def = def
	effect_spd = spd
	description = desc
	equip_slot = slot
	return self

func get_effects() -> Dictionary:
	var effects = {}
	if effect_hp != 0: effects["hp"] = effect_hp
	if effect_mp != 0: effects["mp"] = effect_mp
	if effect_atk != 0: effects["atk"] = effect_atk
	if effect_def != 0: effects["def"] = effect_def
	if effect_spd != 0: effects["spd"] = effect_spd
	return effects
