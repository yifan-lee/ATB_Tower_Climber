# res://core/event_bus.gd
extends Node

# 之前如果写了移动请求信号可以保留，这里新增：
# 发送系统消息的信号，参数是要翻译的文本 Key
signal show_system_message(msg_key: String)