# res://core/event_bus.gd
extends Node

# 之前如果写了移动请求信号可以保留，这里新增：
# 发送系统消息的信号，参数是要翻译的文本 Key
signal show_system_message(msg_key: String)


# [新增] 玩家成功移动到了一个新的网格坐标
signal player_stepped(grid_pos: Vector2i)

# [新增] 请求主程序切换地图 (参数：目标场景路径, 玩家出生的网格坐标)
signal request_map_change(target_scene_path: String, spawn_grid_pos: Vector2i)


signal encounter_monster(entity_id: String, monster_node: Node)

signal battle_ended(result: String)


signal show_skill_menu(skills: Array) # 通知 UI 开启技能菜单
signal player_skill_chosen(skill: Skill) # UI 通知主逻辑玩家选了哪个技能