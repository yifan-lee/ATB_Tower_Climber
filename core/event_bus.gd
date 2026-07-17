# res://core/event_bus.gd
extends Node

# 发送系统消息的信号，参数是要翻译的文本 Key 或 数组
signal show_system_message(msg_data: Variant)

# 物品预览信号
signal preview_item(item_data: Resource)
signal clear_preview()

# 玩家成功移动到了一个新的网格坐标
signal player_stepped(grid_pos: Vector2i)

# 请求主程序切换地图 (参数：目标场景路径, 玩家出生的网格坐标)
signal request_map_change(target_scene_path: String, spawn_grid_pos: Vector2i)

signal encounter_monster(entity_id: String, monster_node: Node)

signal battle_ended(result: String)

signal player_turn_started(skills_info: Array) # 通知技能菜单玩家回合开始并注入数据
signal player_skill_chosen(skill: Skill) # UI 通知主逻辑玩家选了哪个技能
signal preview_skill(skill_data: Dictionary) # 预览技能伤害
signal clear_skill_preview() # 清除预览

# --- 物品系统相关信号 ---
signal inventory_input(event: InputEvent)
signal player_stats_changed()
signal player_item_used()
