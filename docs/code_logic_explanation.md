# ATB_Tower_Climber 游戏架构与代码逻辑深度解析

本文档全面梳理了从游戏启动到玩家操作、战斗、装备及升级的完整数据流与事件调用链。我们使用了 **EventBus (事件总线)** 实现了极致的解耦，并在地图判定上结合了 **物理引擎 (Physics)** 与 **网格逻辑字典 (Grid Logic)** 的混合优势。

---

## 1. 游戏启动时，分别加载了哪些代码？这些代码做了什么？

游戏启动时，引擎会按照以下顺序进行初始化：

1. **Autoloads（单例自动加载）**：
   - `EventBus` (core/event_bus.gd)：最先启动。全局事件总线中心，用来声明所有松耦合的信号（如 `player_stepped`, `encounter_monster`）。
   - `GameConfig` (config/game_config.gd)：定义全局常量，如网格大小（64x64）、屏幕尺寸、墙壁厚度，并提供网格坐标与像素坐标互转的计算函数。
   - `SkillDB` / `ItemDB` / `EntityDB` (config/...)：这些数据库在启动时被实例化，并在 `_ready()` 中将所有硬编码的技能、物品、怪物面板和玩家的初始属性加载到内存的字典（`db`）中。
2. **主场景初始化 (`scenes/main.gd`)**：
   - **创建视图容器**：
     - `game_container` (Control)：屏幕上半部分，用来挂载所有和地图、玩家相关的游戏画面。
     - `ui_container` (Control)：屏幕下半部分，用来挂载文字信息面板和战斗选项。
     - `overlay_layer` (CanvasLayer)：**永远保持在最上层**的独立图层，用来装载全屏或遮罩型的UI（如背包、升级界面、战斗画面）
   - **监听核心信号**
      - `request_map_change`：地图切换
      - `encounter_monster`：遭遇怪物
      - `battle_ended`：战斗结束
      - `show_level_up/hide_level_up`：显示/隐藏升级界面
   - **设置屏幕尺寸 (`_setup_containers`)**
      - `game_container` (Control)：屏幕上半部分，用来挂载所有和地图、玩家相关的游戏画面。
      - `ui_container` (Control)：屏幕下半部分，用来挂载文字信息面板和战斗选项。
      - `overlay_layer` (CanvasLayer)：**永远保持在最上层**的独立图层，用来装载全屏或遮罩型的UI（如背包、升级界面、战斗画面）
   - **依次实例化核心场景 (`_load_initial_scenes`)**：
     - `InfoPanel` (`ui/info_panel.gd`) -> 挂载到 `ui_container`。
       - **设置margin**
       - **设置VBoxContainer来安排info panel布局**：
         - `SystemMessageView` (`ui/system_message_view.gd`)：显示系统消息，占据上半部分
         - `StatInfoView` (`ui/stat_info_view.gd`)：显示玩家属性信息
           - 设置好hp/mp/atk/def/spd五个label
           - 设置监听信号：
             - `encounter_monster`：隐藏信息面板
             - `battle_ended`：显示信息面板
             - `player_stats_changed`：更新属性显示（换装备或者升级）
             - `preview_item`：预览物品信息。如果是装备，会高亮对应装备栏，并显示 stats 增加的数值（加减绿/红色）。如果是药品，会显示可以恢复的数值
             - `clear_preview`：清除物品预览（用当前数值替代）
         - `SkillMenuView` (`ui/skill_menu_view.gd`)：显示技能菜单（仅在战斗时会显示）
           - `_setup_skill_list_box`：设置技能列表
           - `_setup_desc_label_box`：设置技能描述
           - 设置监听信号：
             - `_on_show_skill_menu`：显示技能菜单（传入技能信息）
             - `_on_hide_skill_menu`：隐藏技能菜单
           - `_input`：监听键盘输入，控制光标移动和技能释放。发送信号`player_skill_chosen`。`battle.gd`会监听该信号。
     - `MapFloor1` (`scenes/maps/floor_1.gd`) -> 挂载到 `game_container`。
       - 通过 `_create_boundaries`：创建墙壁（StaticBody2D）
       - 通过 `_setup_tilemap`：创建瓦片地图
       - 通过 `_build_map_from_data`：根据 `map_data` 绘制墙壁、楼梯、生成敌人和物品。
     - `Player` (`entities/player.gd`) -> 初始化其位置并单独挂载到 `game_container`（独立于地图，从而保证地图可以随意切换而不销毁玩家）。
     - `InventoryView` (`ui/inventory_view.gd`) -> 挂载到 `overlay_layer` 并限制其大小为 `game_container` 的尺寸，确保不遮挡底部文本框。
       - **设置布局**：
         - 创建一个 `HBoxContainer` 作为主容器，分为左右两半。
         - 左侧（Left Panel）为分类列表 (`category_list_box`)，包含药品和装备分类。
         - 右侧（Right Panel）为一个带滚动的 `ScrollContainer`（内含 `item_list_box`）以及下方的物品详情描述框 (`RichTextLabel`)。
       - **监听信号**：
         - `show_inventory`：显示背包界面
           - `_refresh_categories`：刷新分类列表
             - `_update_cursors`：更新光标位置。简单的说就是判断一下光标在哪，就高亮哪里，并且发出信号`preview_item`以在底层 InfoPanel 显示属性变化。
           - `_refresh_items`：刷新物品列表
         - `hide_inventory` 来控制显示隐藏和预览信息的清除。发送信号`clear_preview`
       - **交互逻辑 (`_process`)**：通过长按方向键在左右面板和物品列表之间连续顺滑导航（配合 `input_cooldown` 防止过快），回车键使用或装备物品。
         - 使用后更新角色属性、扣除物品并发送 `show_system_message`显示文本。发送`player_stats_changed` 更新 UI。
     - `LevelUpView` (`ui/level_up_view.gd`) -> 挂载到 `overlay_layer`，同样限制尺寸。
       - **设置布局**：
         - 添加一个带透明度(alpha:0.8)的黑色背景 (`ColorRect`) 用于遮罩底层画面。
         - 使用 `VBoxContainer` 居中排列各类属性 Label (HP/MP/ATK/DEF/SPD) 以及最终的确认按钮 [ CONFIRM ]。
       - **监听信号**：监听 `show_level_up` 和 `hide_level_up` 信号，在显示时进入拦截输入模式。
       - **交互逻辑 (`_process`)**：配合 `input_cooldown` 监听上下方向键切换选中项，左右方向键连续分配或取消点数，按回车键进行确认。一旦确认则增加玩家实际属性并重置 `stat_points`，最后发出 `player_stats_changed` 并退出界面。

---

## 2. 游戏启动后，在世界界面的交互

1. **键盘输入**
   - **B键**：打开背包界面
     - 把当前`AppState`设置为`INVENTORY`
     - `_pause_map_and_player`：暂停地图和玩家的进程
     - `EventBus.show_inventory.emit()`：发送`show_inventory`信号，`InventoryView`监听并显示背包界面。
   - **C键**：打开属性界面（等效关闭背包界面）
     - 把当前`AppState`设置为`MAP`
     - `_pause_map_and_player`：暂停地图和玩家的进程
     - `EventBus.hide_inventory.emit()`：发送`hide_inventory`信号，`InventoryView`监听并隐藏背包界面。
   - **Esc键**：等效关闭背包界面（同上）

---

## 3. 游戏开始后，人物和世界的交互

1. **输入捕获**：在 `entities/player.gd` 中的 `_unhandled_input()`，接受上下左右方向键的输入。
2. **计算目标位移**：将方向（`Vector2.RIGHT`）乘以全局常量 `GameConfig.GRID_SIZE`（64），得到移动向量 `motion`。
3. **安全移动检测（纯逻辑网格）**：调用当前地图的 `is_passable(target_grid_pos)` 和 `get_entity_at(target_grid_pos)` 方法：
   - 检查目标网格是否在边界内，以及地形是否是阻挡物（如 `wall`、`door_closed` 等）。
   - 如果遇到阻挡物（地形不可通行）：
     - 拒绝移动，播放待机动画。
     - 发出 `EventBus.show_system_message.emit("MSG_HIT_WALL")`。
   - 如果遇到怪物实体：
     - 拒绝移动，发出 `EventBus.show_system_message.emit("MSG_HIT_ENEMY")`。
     - 发出 `EventBus.encounter_monster.emit`，`main.gd` 会监听该信号并切换战斗场景。
       - 把 `AppState` 设置为 `BATTLE`。
       - 隐藏并暂停探索地图和玩家。
       - 设置战斗场景并加载到最上层节点(`overlay_layer`)。
4. **执行移动**：
   - 如果目标格子地形可通过，且没有怪物实体：
     - 玩家位置瞬间更新 `position = target_pixel_pos`。
     - 播放角色走路动画 (`anim_sprite.play("walk")`)。
     - 发出事件：`EventBus.player_stepped.emit(grid_pos)`，广播“玩家踩在了一个新格子上”。`base_map.gd` 监听该信号：
       - **楼梯/传送门跳转**：如果目标格子在 `stairs_config` 中配置了传送，则 `EventBus` 发出 `request_map_change` 信号。
       - **机关踏板**：如果目标格子在 `triggers_config` 中配置了机关，则调用 `base_map.gd` 中基于**命令模式**的 `trigger_handlers` 字典分发事件（例如 `change_tile` 改变地形开门，或 `give_exp` 给予玩家经验，并触发 `player_stats_changed` 更新界面）。
       - **拾取物品**：如果格子上有物品实体，则加入背包，并发出 `show_system_message` 显示文本，然后从地图上销毁该物品。

---

## 4. 战斗阶段？

1. `_build_top_progress_bar`：初始化进度条、玩家指针和怪物指针
2. `_build_middle_stats`：初始化中间怪物和玩家的属性
3. `_build_bottom_animations`：初始化怪物和玩家的动画
4. `_process`：
  - 检查游戏是不是已经暂停了，暂停就直接 return
  - 给玩家和怪物进度条累加值。
  - 给技能减少CD
  - 判断玩家是不是走完了进度条，如果是，就：
    - 暂停游戏
    - 对玩家的每个技能计算预估伤害`estimated_damage`
    - 发出信号`show_skill_menu`。`ui/skill_menu_view.gd`会监听该信号。
      - 展示所有技能
      - 发送`player_skill_chosen`信号回来
        - 更新选择技能cd
        - 计算伤害并执行
          - 如果导致怪物死亡
            - 玩家获得经验值
            - 发送`battle_ended`信号。
              - `ui/skill_menu_view.gd`接收信号并且隐藏技能栏
              - `scenes/main.gd`接收信号
                - 删除战斗场景
                - 如果胜利，删除怪物
                - 恢复地图和玩家
                - 如果经验足够，发送`show_level_up`信号，`ui/level_up_view.gd`监听该信号。（下面解释）
          - 否则就让玩家进度条重制
  - 判断怪物是不是走完了进度条，如果是，就：
    - 暂停游戏
    - 怪物随机选择技能
  - 都没有走完进度条就继续更新进度条

---

## 5. 战斗结束后，升级

1. **展示五个属性的加点界面**
2. **根据指针位置刷新这五个属性**：加上">xxxxx<"来表示当前选中的属性
3. **监控方向键输入**：
  - 上下就是刷新步骤2
  - 左右就要增减属性
  - 在确认上按回车就是分配完属性。
  - 发出信号`player_stats_changed`，`ui/stat_info_view.gd`监听该信号并刷新信息
  - 发出信号`hide_level_up`
4. **技能领悟**：
  - 在获得经验 (`gain_exp`) 导致升级时，系统会检查 `level_up_skills` 字典。如果达到特定等级，会自动学习新技能并广播提示。



---


## 6. 战斗启动时，哪些代码加载了，又做了什么？

1. **主程序调度**：在 `main.gd` 的 `_on_encounter_monster` 中：
   - 将程序状态机切换为 `AppState.BATTLE`。
   - 禁用并隐藏当前地图 (`current_map.hide()`) 和 玩家实体 (`player_instance.hide()`)。
2. **场景挂载**：实例化全新的 `scenes/battle.gd` (战斗场景核心)，将其挂载到 `game_container` 中覆盖屏幕。
3. **数据初始化**：
   - 调用 `BattleScene.setup(monster_id)`。
   - 向 `EntityDB` 查询 `player` 和对应 `monster_id` 的属性（HP、MP、技能等），并将当前血量重置为最大血量。
   - 实例化两侧的战斗角色UI、ATB进度条组件。
4. **启动循环**：启动内置的物理帧 `_physics_process(delta)`，双方的 ATB 能量开始随着速度（SPD）不断上涨。

---

## 7. 我在战斗时选择技能，调用了哪些代码？

1. **ATB 就绪**：玩家 ATB 满格后，战斗场景抛出 `EventBus.show_skill_menu.emit`。
2. **UI 渲染**：下方的技能面板捕获信号，根据 `EntityDB` 中玩家持有的技能列表，动态生成按钮，并调用公式提前计算“预估伤害”。
3. **点击技能**：玩家点击按钮，触发 `EventBus.player_skill_chosen(skill_id)`，下方面板隐藏。
4. **核心结算**：
   - 战斗主逻辑监听到玩家选了技能，播放角色的“攻击”动画。
   - 运行伤害公式：`(攻击力 * 技能倍率) - 敌方防御`。
   - 扣除对应方 HP，播放受击动画或飘字效果。
   - 将释放者的 ATB 清零，战斗循环继续。

---

## 8. 战斗结束后，会发生哪些事情？

1. **胜利结算**：当怪物 HP 归零，`BattleScene` 发出 `EventBus.battle_ended("win")`，并自身 `queue_free()` 销毁退出。
2. **销毁地图残骸**：`main.gd` 收到胜利信号后，立刻将缓存起来的、位于地图上的那个怪物物理节点执行 `queue_free()` 彻底删除。
3. **恢复探索**：调用 `_resume_map_and_player()`，把隐藏的地图和玩家重新 `show()` 出来，玩家刚好站在击败怪物前的位置上。
4. **检测升级**：如果是升级系统介入，会判断玩家是否有可用加点（`stat_points > 0`），有则触发升级界面。

---

## 9. 升级界面怎么触发，又怎么结束？

1. **触发机制**：战斗结束或通过某些道具触发 `EventBus.show_level_up.emit()`。
2. **挂起游戏**：`main.gd` 捕获后，将状态锁定（如复用 `AppState.INVENTORY`），禁止玩家控制地图移动，并冻结地图树的运行。
3. **渲染 UI**：`ui/level_up_view.gd`（启动时就在顶层隐藏待命）变得可见。读取玩家的剩余 `stat_points`，动态激活面板上的 `+` 号按钮。
4. **结束并恢复**：当点数分配完毕，玩家点击“确定”按钮。界面执行内部属性覆盖（直接修改 `EntityDB` 中的玩家实例），随后抛出 `EventBus.hide_level_up.emit()`，重新隐藏面板并恢复地图控制权。

---

## 10. 装备系统是怎么运作的？

装备系统巧妙融合了纯逻辑驱动与 UI 刷新系统：

1. **数据驱动的地图拾取**：
   - 道具生成在 `base_map.gd` 时，并**没有任何物理体**，仅仅是一个显示在屏幕上的 `Sprite2D`，并将坐标 `[x,y]` 记录在名为 `map_items` 的隐形字典里。
   - 玩家走上去时（如楼梯的机制），触发落步信号。地图查询 `map_items`，发现踩中道具，直接将道具 ID 塞入玩家 `Stats` 的 `inventory` 数组，并销毁该 `Sprite2D` 节点。
2. **打开背包**：按下 `B` 键，唤出 `inventory_view.gd`，暂停地图操作。
3. **穿脱装备**：
   - 当点击装备栏图标，逻辑检查 `EntityDB` 中该物品的槽位（例如 `HEAD`）。
   - 覆盖玩家 `Stats` 属性下的 `equipment` 字典（如 `equipment[EquipSlot.HEAD] = "iron_helm"`）。
4. **属性计算**：战斗时或面板显示时，调用 `get_total_stats()`，该方法会遍历身上所有穿戴中的装备，将其附带的攻防血属性叠加在基础面板上进行最终计算。
