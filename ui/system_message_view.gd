# res://ui/system_message_view.gd
extends PanelContainer

var message_label: Label
var ignore_input_timer: float = 0.0

func _ready():
	# UI Styling
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7) # 半透明黑色底色
	add_theme_stylebox_override("panel", style)
	
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_top", 12)
	margin_container.add_theme_constant_override("margin_bottom", 12)
	margin_container.add_theme_constant_override("margin_left", 24)
	margin_container.add_theme_constant_override("margin_right", 24)
	add_child(margin_container)
	
	message_label = Label.new()
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	margin_container.add_child(message_label)
	
	hide() # 初始隐藏
	set_process(false)
	
	EventBus.show_system_message.connect(_on_show_system_message)
	
	# 如果想一进游戏就弹出一条欢迎语可以手动发个信号：
	# EventBus.show_system_message.emit("MSG_WELCOME")

func _on_show_system_message(msg_data: Variant):
	var final_text = ""
	if typeof(msg_data) == TYPE_STRING:
		final_text = tr(msg_data)
	elif typeof(msg_data) == TYPE_ARRAY:
		for part in msg_data:
			final_text += tr(part)
			
	if final_text != "":
		message_label.text = final_text
		show()
		ignore_input_timer = 0.1 # 0.1秒的防抖保护
		set_process(true)
	else:
		hide()

func _process(delta: float):
	if ignore_input_timer > 0:
		ignore_input_timer -= delta
		if ignore_input_timer <= 0:
			set_process(false)

func _input(event):
	if not visible or ignore_input_timer > 0:
		return
		
	# 只要是有按键按下，并且不是长按的回音，就清空文字并隐藏
	if event is InputEventKey and event.pressed and not event.echo:
		hide()
