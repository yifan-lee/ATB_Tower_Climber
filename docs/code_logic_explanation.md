# ATB_Tower_Climber 代码执行逻辑解析

本文档完全依照代码执行顺序（从 `main.gd` 开始），逐行解释每一行代码背后的逻辑。跳过基础UI的位置与颜色设置代码。

## 初始化 (`main.gd` 的 `_ready`)
- 新建 `game_container`，`ui_container`，`overlay_canvas`，`overlay_layer1`，`overlay_layer2`，`notification_canvas`，`system_message_view` 容器
- 监听信号 `request_map_change` 绑定到 `_on_map_change_requested`
- 监听信号 `encounter_monster` 绑定到 `_on_encounter_monster`
- 监听信号 `battle_ended` 绑定到 `_on_battle_ended`
- `_setup_containers`:
  - 设置 `game_container`，`ui_container`，`overlay_layer1`，`overlay_layer2`，`system_message_view` 容器位置和大小
- `_load_initial_scenes`:
  - 定义 `initial_map_path` 为 `"res://scenes/maps/floor_1.gd"`
  - 新建 MapFloor1:
    - 调用 `res://scenes/maps/floor_1.gd`:
      - **`_init`**:
        - 定义 `floor_name_key` 为 `"MAP_FLOOR_1_NAME"`
        - 定义 `floor_desc_key` 为 `"MAP_FLOOR_1_DESC"`
        - 定义 `map_data`，这是一个11x11的二维数组，设定网格每一格的地形与内容
        - 定义 `stairs_config`，设置 `(5, 0)` 会传送到二楼的 `(5, 0)` 坐标
        - 定义 `triggers_config`，设置在 `(5, 4)` 位置踩踏后的一系列机关触发数据
    - 调用 `res://scenes/maps/base_map.gd` (父类):
      - **`_ready`**:
        - 创建 `floor_bg` 背景
        - `_draw_aesthetic_boundaries`:
          - 计算并在地图四周添加四条边界墙壁的矩形 `_add_border_rect`
        - `_build_map_grids`:
          - 遍历 `GameConfig.GRID_ROWS` 和 `GRID_COLUMNS`
          - 为每个格子新建一个 `Sprite2D`，计算像素位置并加入场景
          - 解析 `map_data[y][x]` 的字符串值
          - 如果为空或是"0"，视为 `"floor"`
          - 如果是地貌字符串如 `"wall"`, `"door_closed"`, 则保持原值
          - 如果是 `EntityDB.db` 中的怪物，调用 `_spawn_entity` 并在当前格子留底 `"floor"`
          - 如果是 `ItemDB.db` 中的物品，同样调用 `_spawn_entity`
          - 把 `MapDB.get_texture` 取得的贴图赋给格子精灵，并根据配置缩放
  - `game_container.add_child(current_map)` 将地图加进游戏容器
  - `loaded_maps[initial_map_path] = current_map` 缓存第一层地图
  - 新建 Player:
    - 调用 `res://entities/player.gd`:
      - **`_ready`**:
        - `add_to_group("player")` 加入玩家组
        - `z_index = 10` 强制玩家渲染层级在最上，避免被地图遮挡
        - `_setup_sprite`:
          - `EntityDB.get_stats("player")` 获取玩家面板数据
          - 利用获取到的动画路径调用 `GameConfig.create_scaled_anim_sprite` 生成人物动画并添加
  - 计算 `GameConfig.get_game_area_pixel_position` 将玩家放置到初始网格对应的像素位置
  - `game_container.add_child(player_instance)` 将玩家加进游戏容器
  - 新建 StatInfoView:
    - 调用 `res://ui/stat_info_view.gd`:
      - **`_ready`**:
        - `EntityDB.get_stats("player")` 缓存玩家数据
        - `_update_stats`: 更新界面上的各个文本 Label 属性数值
        - 监听 `encounter_monster` 和 `battle_ended` 控制可见性
        - 监听 `player_stats_changed`, `preview_item`, `clear_preview` 控制界面刷新
  - 新建 LevelUpView，并监听其 `level_up_completed`
  - 新建 SkillMenuView, InventoryView, InfoPanel 
  - `_update_floor_info`:
    - 若 `info_panel` 和 `current_map` 存在，调用 `info_panel.refresh_floor_info(current_map)` 刷新底层地名
    - 调用 `info_panel.refresh_player_stats()` 刷新底层玩家概览数据
- `change_state(AppState.MAP)`:
  - 隐藏所有覆盖的UI层级与界面
  - 若 `current_battle` 存在则隐藏
  - `_pause_map_and_player`:
    - 禁用地图 `process_mode = Node.PROCESS_MODE_DISABLED`
    - 禁用玩家 `process_mode = Node.PROCESS_MODE_DISABLED`
  - `current_state = new_state` (在此处为MAP)
  - 匹配 `new_state` 为 `AppState.MAP`:
    - `_resume_map_and_player`:
      - 将地图与玩家的 `process_mode` 恢复为 `INHERIT`
    - 显示 `info_panel`

## 玩家循环 (`main.gd` 没有 _process，看 `player.gd`)
调用 `res://entities/player.gd`:
- **`_process`**:
  - 如果 `move_cooldown > 0`，将冷却时间扣减 `delta` 并返回，避免单帧多次移动
  - 通过 `GameConfig` 检查上下左右按键，赋值给 `direction`
  - 如果按下了方向键 (`direction != Vector2.ZERO`):
    - `_try_move(direction)`:
      - 计算 `target_pixel_pos` 和 `target_grid_pos`
      - 获取 `current_map` 节点
      - 若 `map_node.is_passable(target_grid_pos)` 为 `false`（不可通行）：
        - 播放 `idle` 动画
        - 发送系统消息 `"MSG_HIT_WALL"` 并返回
      - 调用 `map_node.get_entity_at(target_grid_pos)` 获取格子实体
      - 如果有实体且 `is_enemy` 为 `true`:
        - 播放 `idle` 动画，发送系统消息 `"MSG_HIT_ENEMY"`
        - 触发 `EventBus.encounter_monster.emit(entity["id"], entity["node"])` 广播遇敌，并返回
      - 检查地图特定的自定义移动规则 `check_custom_move_rules`（若有）
      - 将玩家的 `position` 设置为 `target_pixel_pos`，播放 `"walk"` 动画
      - 发出 `EventBus.player_stepped.emit(target_grid_pos)`，通知地图玩家踩到了新格子
    - 重置 `move_cooldown = MOVE_DELAY` 设定移动延迟冷却时间

## 按键输入监听 (`main.gd` 的 `_input`)
- 判断输入事件是键盘按下且不是重复触发 (`echo`)
- 如果按下 `KEY_B`:
  - 若 `current_state == AppState.MAP`:
    - 调用 `change_state(AppState.INVENTORY)` 进入背包界面，会暂停玩家和地图并显示背包 UI
- 如果按下 `KEY_C` 或 `KEY_ESCAPE`:
  - 若 `current_state == AppState.INVENTORY`:
    - `inventory_view.clear()` 清理高亮与预览状态
    - `change_state(AppState.MAP)` 回到地图探索状态

## 战斗流转逻辑 (`main.gd` 的 `_on_encounter_monster` 回调)
- `current_enemy_node = monster_node` 缓存撞到的怪物节点在全局变量中
- 新建 BattleScene:
  - 调用 `res://scenes/battle.gd`:
    - **`_ready`**:
      - 创建并添加纯色背景
      - `_build_top_progress_bar`: 创建进度条背景与玩家/怪物的头像指针，设为静态动画
      - `_build_middle_stats`: 实例化两个 `EntityStatView` 塞入中间的HBox展示双方数值
      - `_build_bottom_animations`: 放置放大后的双方战斗动画模型
      - 根据玩家与怪物的总速度（`get_total_spd`）计算出进度条上的移动速度 `p_speed_px` 与 `e_speed_px`
      - 监听 `player_skill_chosen` 等相关事件
- `current_battle.setup(monster_id)`:
  - **`setup`**:
    - `player_stats = EntityDB.get_stats("player")` 直接获取玩家全局面板以继承血量
    - `enemy_stats = EntityDB.get_stats(enemy_id).duplicate(true)` 深拷贝怪物面板数据防止污染全局原图鉴
- 设置战斗UI锚点，并将其加入 `overlay_layer1`
- `change_state(AppState.BATTLE)` 将全局状态设为战斗，停滞地图并展示所有战斗覆盖UI

## 战斗引擎循环 (`battle.gd` 的 `_process`)
- 如果 `is_action_paused` 为真，代表系统等待中，直接返回冻结时间
- 累加玩家与怪物的当前进度 `p_progress += p_speed_px * delta` 和 `e_progress += e_speed_px * delta`
- 遍历并扣减玩家、怪物所有携带技能的冷却时间 (`current_cd -= delta`)
- 如果玩家进度达到 `BAR_WIDTH`:
  - 进度封顶为 `BAR_WIDTH`，并锁定时间 `is_action_paused = true`
  - 标记 `ready_character = "player"`
  - 遍历玩家拥有的技能，利用 `CombatFormula.calculate_damage` 用攻防数值预估每个技能的伤害
  - 发射信号 `EventBus.player_turn_started.emit(skills_info)`，通知下方的技能选单界面弹出选项
- 否则如果怪物进度达到 `BAR_WIDTH`:
  - 进度封顶为 `BAR_WIDTH`，锁定时间 `is_action_paused = true`
  - 标记 `ready_character = "enemy"`
  - 通过 `create_timer(1.0).timeout` 创建1秒延迟后，回调敌方回合 `_on_enemy_turn` 模拟思考时间

## 战斗结算与收尾
当外部菜单决定了玩家要释放的技能后触发 (`battle.gd` 的 `_on_player_skill_chosen`)
- 将被选中技能的 `current_cd` 设为满值
- `_execute_skill(player_stats, enemy_stats, skill)`:
  - 扣除玩家当前的 MP
  - `CombatFormula.calculate_damage` 算出真实伤害数值 `final_damage`
  - 扣除敌方的 HP（最多扣到0）
  - 同步刷新界面上双方的文本数值，并返回此伤害值
- 通过 `show_system_message` 信号弹出伤害播报信息
- 判断怪物血量是否归零 (`enemy_stats.current_hp <= 0`):
  - 结算怪物经验 `get_exp_yield`，并加给玩家 `player_stats.gain_exp`
  - 播报获得经验的系统消息
  - 广播战斗结束且结果为胜利：`EventBus.battle_ended.emit("win")`
- 如果怪物还活着:
  - `_resume_battle(true)`: 将玩家进度条清零，并解锁 `is_action_paused` 为 false 继续跑时间

当收到战斗结束信号时 (`main.gd` 的 `_on_battle_ended`)
- 如果 `current_battle` 存在，调用 `queue_free()` 销毁战斗场景释放内存，并将其变量置空
- 如果战斗结果是 `"win"` 且存有之前缓存的怪物节点：
  - 如果地图实现了 `remove_entity_by_node`，则通知地图彻底拔除该实体，否则直接将该节点 `queue_free`
- 清空 `current_enemy_node`
- `EntityDB.get_stats("player")` 获取玩家最新数据
- 如果 `stat_points > 0` (刚刚获得的经验导致了玩家升级)：
  - `change_state(AppState.LEVEL_UP)` 切入升级界面
- 否则直接 `change_state(AppState.MAP)` 切回地图模式继续游戏探索
