# res://ui/system_message_view.gd
extends Label

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_TOP
	autowrap_mode = TextServer.AUTOWRAP_WORD
	text = tr("MSG_WELCOME")
	
	EventBus.show_system_message.connect(_on_show_system_message)

func _on_show_system_message(msg_data: Variant):
	show()
	if typeof(msg_data) == TYPE_STRING:
		text = tr(msg_data)
	elif typeof(msg_data) == TYPE_ARRAY:
		var final_text = ""
		for part in msg_data:
			final_text += tr(part)
		text = final_text
