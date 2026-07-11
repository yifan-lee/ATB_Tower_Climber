extends Control
class_name BattleUI

# 准备好节点引用 (注意检查节点名字是否和你创建的一致)
@onready var player_image = $PlayerImage
@onready var enemy_image = $EnemyImage

@onready var p_name_label = $CenterStats/PlayerStatsBox/NameLabel
@onready var p_hp_label = $CenterStats/PlayerStatsBox/CurrentHPLabel
@onready var p_atk_label = $CenterStats/PlayerStatsBox/AtkLabel
@onready var p_def_label = $CenterStats/PlayerStatsBox/DefLabel

@onready var e_name_label = $CenterStats/EnemyStatsBox/NameLabel
@onready var e_hp_label = $CenterStats/EnemyStatsBox/CurrentHPLabel
@onready var e_atk_label = $CenterStats/EnemyStatsBox/AtkLabel
@onready var e_def_label = $CenterStats/EnemyStatsBox/DefLabel

func _ready():
    # 战斗 UI 加载时，我们先把它隐藏起来
    hide()

# 核心函数：大地图触发战斗时，调用这个函数并传入数据
func start_battle(player_data: CharacterStats, enemy_data: CharacterStats):
    show() # 显示战斗界面
    
    # --- 1. 设置动画 ---
    # 检查玩家数据里有没有配好的动画资源
    if player_data.sprite_frames:
        player_image.sprite_frames = player_data.sprite_frames
        player_image.play("idle") # 播放待机动画（"idle"替换成你切图时起的名字）
        
    # 检查敌人数据里有没有配好的动画资源
    if enemy_data.sprite_frames:
        enemy_image.sprite_frames = enemy_data.sprite_frames
        enemy_image.play("idle")

    # --- 2. 设置玩家数值 ---
    p_name_label.text = "【" + player_data.character_name + "】"
    p_hp_label.text = "HP: " + str(player_data.current_hp) + " / " + str(player_data.max_hp)
    p_atk_label.text = "ATK: " + str(player_data.atk)
    p_def_label.text = "DEF: " + str(player_data.def)
    
    # --- 3. 设置敌人数值 ---
    e_name_label.text = "【" + enemy_data.character_name + "】"
    e_hp_label.text = "HP: " + str(enemy_data.current_hp) + " / " + str(enemy_data.max_hp)
    e_atk_label.text = "ATK: " + str(enemy_data.atk)
    e_def_label.text = "DEF: " + str(enemy_data.def)
    
    print("战斗界面已加载，准备就绪！")