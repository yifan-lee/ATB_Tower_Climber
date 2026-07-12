# res://ui/info_panel.gd
extends ColorRect

var message_label: Label

func _ready():
    self.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.INFO_AREA_HEIGHT)
    # 设置一个深灰色的背景作为占位
    self.color = Color(0.15, 0.15, 0.15)

    _setup_label()
    
    # 监听全局消息信号
    EventBus.show_system_message.connect(_on_show_system_message)


func _setup_label():
    message_label = Label.new()
    # 纯代码设置文本居中和边界留白
    message_label.set_anchors_preset(Control.PRESET_FULL_RECT)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    
    # 默认显示一段欢迎语（记得在你的 texts.csv 里配上 MSG_WELCOME）
    message_label.text = tr("MSG_WELCOME")
    add_child(message_label)

func _on_show_system_message(msg_key: String):
    # 使用 tr() 自动根据当前语言映射 CSV 里的翻译内容
    message_label.text = tr(msg_key)