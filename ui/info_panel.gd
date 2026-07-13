# res://ui/info_panel.gd
extends ColorRect

var message_label: Label
var menu_container: HBoxContainer
var skill_list_box: VBoxContainer
var skill_desc_label: Label

var is_menu_active: bool = false
var available_skills: Array = []
var current_selection: int = 0
var skill_labels: Array = [] # 存放技能文本节点的引用

func _ready():
    # 设置一个深灰色的背景作为占位
    self.color = Color(0.15, 0.15, 0.15)
    self.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.INFO_AREA_HEIGHT)
    
    _setup_ui_elements()

    # _setup_label()
    
    # 监听全局消息信号
    EventBus.show_system_message.connect(_on_show_system_message)
    EventBus.show_skill_menu.connect(_on_show_skill_menu)


func _setup_ui_elements():
    # 1. 纯文本展示区 (平时跑图/看剧情用)
    message_label = Label.new()
    message_label.set_anchors_preset(Control.PRESET_FULL_RECT)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    add_child(message_label)

    # 2. 技能菜单容器 (战斗选技能用)
    menu_container = HBoxContainer.new()
    menu_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    menu_container.hide() # 默认隐藏
    add_child(menu_container)

    # 左侧：技能列表
    skill_list_box = VBoxContainer.new()
    skill_list_box.custom_minimum_size = Vector2(140, 160)
    menu_container.add_child(skill_list_box)
    
    # 右侧：技能描述
    skill_desc_label = Label.new()
    skill_desc_label.custom_minimum_size = Vector2(160, 160)
    skill_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    menu_container.add_child(skill_desc_label)

func _on_show_system_message(msg_key: String):
    is_menu_active = false
    menu_container.hide()
    message_label.show()
    message_label.text = tr(msg_key)

func _on_show_skill_menu(skills: Array):
    message_label.hide()
    menu_container.show()
    
    available_skills = skills
    current_selection = 0
    is_menu_active = true
    
    # 清空旧的技能列表
    for child in skill_list_box.get_children():
        child.queue_free()
    skill_labels.clear()
    
    # 纯代码动态生成技能条目
    for i in range(skills.size()):
        var skill = skills[i]
        var lbl = Label.new()
        # 如果冷却没好，显示CD
        if skill.current_cd > 0:
            lbl.text = "   " + tr(skill.skill_name) + " (CD:" + str(ceil(skill.current_cd)) + ")"
            lbl.modulate = Color(0.5, 0.5, 0.5) # 置灰
        else:
            lbl.text = "   " + tr(skill.skill_name)
            
        skill_list_box.add_child(lbl)
        skill_labels.append(lbl)
        
    _update_menu_cursor()

func _update_menu_cursor():
    for i in range(skill_labels.size()):
        var skill = available_skills[i]
        if i == current_selection:
            # 加上光标 >
            skill_labels[i].text = "> " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")
            skill_desc_label.text = tr(skill.description) + "\n伤害: +" + str(skill.damage)
        else:
            # 移除光标
            skill_labels[i].text = "   " + skill_labels[i].text.trim_prefix("   ").trim_prefix("> ")

# 纯代码拦截并处理键盘选择
func _input(event):
    if not is_menu_active:
        return
        
    if event.is_action_pressed("ui_up"):
        current_selection = max(0, current_selection - 1)
        _update_menu_cursor()
    elif event.is_action_pressed("ui_down"):
        current_selection = min(available_skills.size() - 1, current_selection + 1)
        _update_menu_cursor()
    elif event.is_action_pressed("ui_accept"): # 默认是空格或回车
        var chosen_skill = available_skills[current_selection]
        if chosen_skill.current_cd <= 0:
            is_menu_active = false
            # 向主战斗逻辑发送玩家的决定！
            EventBus.player_skill_chosen.emit(chosen_skill)

# func _setup_label():
#     message_label = Label.new()
#     # 纯代码设置文本居中和边界留白
#     message_label.set_anchors_preset(Control.PRESET_FULL_RECT)
#     message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
#     message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    
#     # 默认显示一段欢迎语（记得在你的 texts.csv 里配上 MSG_WELCOME）
#     message_label.text = tr("MSG_WELCOME")
#     add_child(message_label)
