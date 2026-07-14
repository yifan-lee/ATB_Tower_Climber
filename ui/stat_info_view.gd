# res://ui/stat_info_view.gd
extends HBoxContainer

var player_stats: Stats

var hp_lbl: Label
var atk_lbl: Label
var def_lbl: Label
var spd_lbl: Label

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	player_stats = EntityDB.get_stats("player")
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(vbox) # 修复了原先没有 add_child 的问题

	vbox.add_child(_create_label(player_stats.entity_name, Color(1, 1, 0)))
	hp_lbl = _create_label("")
	atk_lbl = _create_label("")
	def_lbl = _create_label("")
	spd_lbl = _create_label("")

	vbox.add_child(hp_lbl)
	vbox.add_child(atk_lbl)
	vbox.add_child(def_lbl)
	vbox.add_child(spd_lbl)

	_update_stats()

	# 监听现成的战斗全局事件
	EventBus.encounter_monster.connect(_on_encounter_monster)
	EventBus.battle_ended.connect(_on_battle_ended)

func _create_label(text: String, color: Color = Color.WHITE) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	return lbl

func _update_stats():
	hp_lbl.text = "HP: " + str(player_stats.current_hp) + "/" + str(player_stats.max_hp)
	atk_lbl.text = "ATK: " + str(player_stats.atk)
	def_lbl.text = "DEF: " + str(player_stats.def)
	spd_lbl.text = "SPD: " + str(player_stats.spd)

func _on_encounter_monster(_id: String, _node: Node):
	visible = false

func _on_battle_ended(_result: String):
	_update_stats()
	visible = true
