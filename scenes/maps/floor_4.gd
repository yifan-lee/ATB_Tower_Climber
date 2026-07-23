# res://scenes/maps/floor_4.gd
extends "res://scenes/maps/base_map.gd"

func _init() -> void:
	config = {"floor": 4, "name": "MAP_FLOOR_NAME_LEFT_RULE", "desc": "MAP_FLOOR_DESC_LEFT_RULE"}
	map_data = [
		["           ", "monster_basic_lv2", "                 ", "monster_basic_lv2", "hp_herb_lv1      ", "mp_herb_lv1      ", "hp_herb_lv1      ", "mp_herb_lv1      ", "dagger_lv1       ", "monster_basic_lv2", "                 "],
		["hp_herb_lv1", "wall             ", "                 ", "wall             ", "monster_basic_lv2", "wall             ", "monster_basic_lv2", "wall             ", "wall             ", "wall             ", "monster_basic_lv2"],
		["mp_herb_lv1", "wall             ", "                 ", "fragment_red     ", "                 ", "                 ", "                 ", "monster_basic_lv2", "bracers_lv1      ", "                 ", "                 "],
		["hp_herb_lv1", "wall             ", "monster_basic_lv1", "wall             ", "monster_basic_lv2", "wall             ", "wall             ", "wall             ", "monster_basic_lv1", "wall             ", "hp_herb_lv1      "],
		["mp_herb_lv1", "wall             ", "monster_basic_lv1", "wall             ", "                 ", "fragment_red     ", "fragment_yellow  ", "monster_basic_lv2", "spirit_stone     ", "wall             ", "                 "],
		["           ", "monster_basic_lv2", "monster_basic_lv2", "fragment_yellow  ", "                 ", "fragment_blue    ", "fragment_white   ", "wall             ", "monster_basic_lv1", "wall             ", "monster_basic_lv1"],
		["wall       ", "wall             ", "                 ", "wall             ", "                 ", "wall             ", "wall             ", "wall             ", "                 ", "wall             ", "monster_basic_lv1"],
		["wall       ", "wall             ", "                 ", "monster_basic_lv2", "spirit_stone     ", "spirit_stone     ", "spirit_stone     ", "monster_basic_lv2", "                 ", "wall             ", "                 "],
		["wall       ", "wall             ", "monster_basic_lv2", "wall             ", "wall             ", "wall             ", "monster_basic_lv2", "wall             ", "monster_basic_lv1", "wall             ", "leggings_lv1     "],
		["wall       ", "wall             ", "                 ", "monster_basic_lv1", "fragment_blue    ", "monster_basic_lv1", "                 ", "hp_herb_lv1      ", "                 ", "                 ", "                 "],
		["wall       ", "wall             ", "stair_up         ", "wall             ", "wall             ", "wall             ", "wall             ", "wall             ", "stair_down       ", "wall             ", "wall             "],
	]


	stairs_config = {
		Vector2i(8, 10): {
			"target_scene": "res://scenes/maps/floor_3.gd",
			"spawn_grid": Vector2i(8, 10)
		},
        Vector2i(2, 10): {
			"target_scene": "res://scenes/maps/floor_5.gd",
			"spawn_grid": Vector2i(2, 10)
		},
	}

var last_direction: Vector2i = Vector2i.ZERO

func check_custom_move_rules(current_pos: Vector2i, target_pos: Vector2i, direction: Vector2i) -> bool:
	if custom_state.get("rule_disabled", false):
		return true

	if last_direction != Vector2i.ZERO:
		var relative_left = Vector2i(last_direction.y, -last_direction.x)
		var backward = - last_direction
		
		if direction == relative_left or direction == backward:
			EventBus.show_system_message.emit("MSG_RULES_VIOLATED")
			var player = get_tree().get_nodes_in_group("player")[0]
			player.position = GameConfig.get_game_area_pixel_position(8, 10)
			last_direction = Vector2i.ZERO
			return false
			
	last_direction = direction
	return true

func _on_player_stepped(grid_pos: Vector2i):
	var terrain = str(map_data[grid_pos.y][grid_pos.x])
	if terrain == "stair_up":
		custom_state["rule_disabled"] = true
	super._on_player_stepped(grid_pos)

	# stair_down, stair_up, pedal_switch, door_closed
	# fragment_blue, fragment_red, fragment_yellow, fragment_white, spirit_stone
	# monster_def_lv1, monster_atk_lv1, monster_spd_lv1, monster_basic_lv1
	# hp_herb_lv1, mp_herb_lv1, 
	# helm_lv1, chestplate_lv1, leggings_lv1, bracers_lv1, boot_lv1, 
	# sword_lv1, blade_lv1, dagger_lv1, shield_lv1, spear_lv1, fan_lv1, staff_lv1