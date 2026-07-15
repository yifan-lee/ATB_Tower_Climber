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
     - `game_container` (Control)：屏幕上半部分，用来挂载所有和地图、战斗相关的游戏画面。
     - `ui_container` (Control)：屏幕下半部分，用来挂载文字信息面板。
     - `overlay_layer` (CanvasLayer)：**永远保持在最上层**的独立图层，用来装载全屏或遮罩型的UI（如背包、升级界面），彻底解决了被后续加载的地图覆盖的Bug。
   - **监听核心信号**（如地图切换、遭遇怪物、战斗结束、升级等）。
   - **依次实例化核心场景 (`_load_initial_scenes`)**：
     - `InfoPanel` (`ui/info_panel.gd`) -> 挂载到 `ui_container`。
     - `MapFloor1` (`scenes/maps/floor_1.gd`) -> 挂载到 `game_container`。
     - `Player` (`entities/player.gd`) -> 初始化其位置 `(0,0)` 并单独挂载到 `game_container`（独立于地图，从而保证地图可以随意切换而不销毁玩家）。
     - `InventoryView` (`ui/inventory_view.gd`) -> 挂载到 `overlay_layer` 并限制其大小为 `game_container` 的尺寸，确保不遮挡底部文本框。
     - `LevelUpView` (`ui/level_up_view.gd`) -> 挂载到 `overlay_layer`，同样限制尺寸。

---

## 2. 游戏开始后，我按下方向键到玩家移动，代码是怎么触发的？

1. **输入捕获**：在 `entities/player.gd` 中的 `_physics_process()`，通过 `Input.is_action_just_pressed` 捕获到单次按键（如 `ui_right`）。
2. **计算目标位移**：将方向（`Vector2.RIGHT`）乘以全局常量 `GameConfig.GRID_SIZE`（64），得到移动向量 `motion`。
3. **安全移动检测**：调用 Godot 的底层物理方法 `test_move(current_transform, motion, collision)`：
   - 物理引擎会在内存中模拟“如果玩家向右移动 64 像素，会不会碰到带有碰撞体的节点（PhysicsBody2D）”。
4. **执行移动**：
   - 如果返回 `false`（前方没有任何阻挡物理体的节点）：玩家的位置瞬间更新 `position += motion`。
   - 播放角色走路动画 (`anim_sprite.play("walk")`)。
   - 发出事件：`EventBus.player_stepped.emit(grid_pos)`，广播“玩家成功踩在了一个新格子上”。

---

## 3. 我按下方向键，撞到了墙壁，代码怎么触发的？

1. **物理阻挡**：`player.gd` 中的 `test_move()` 返回了 `true`。
2. **进入交互判断**：移动被取消（不会执行 `position += motion`），调用 `_handle_interaction(collider)` 函数，并将撞击的节点（墙壁）传入。
3. **类型识别**：在 `_handle_interaction` 中，代码判断这个节点是不是 `TileMap`（内部墙壁）或者 `StaticBody2D`（边缘墙壁）。
4. **发出文本事件**：匹配成功后，玩家播放 `idle` 动画，代码发出 `EventBus.show_system_message.emit("MSG_HIT_WALL")`。下方的 UI 面板监听到后，显示“哎哟！前面是一堵墙”。

---

## 4. 我按下方向键，撞到了楼梯，代码怎么触发？

1. **物理畅通无阻**：楼梯**没有**物理碰撞体，只是图集（TileMap）里的背景图案。因此，`test_move()` 返回 `false`，玩家顺利移动到了楼梯所在的格子上。
2. **广播落步信号**：玩家位置更新后，发出了 `EventBus.player_stepped.emit(grid_pos)`。
3. **地图字典拦截**：`scenes/maps/base_map.gd`（当前正在激活的地图实例）监听到了玩家落步。它会检查自身的 `stairs_config` 字典，看看玩家刚踩的这个坐标是不是楼梯入口。
4. **切换地图**：查字典发现匹配成功，地图发出 `EventBus.request_map_change.emit(target_scene, spawn_grid)` 信号。
5. **主逻辑执行**：`main.gd` 接收到信号，暂停并隐藏当前地图，将玩家位置重置到下一层楼梯的出口坐标，然后加载或显示目标楼层地图。

---

## 5. 我按下方向键，撞到了怪物，怎么触发开始战斗？

1. **物理阻挡**：地图生成怪物时，赋予了它们 `CharacterBody2D` 并带有物理碰撞框。玩家试图走过去时，`test_move()` 判定被阻挡，返回 `true`。
2. **交互判定**：进入 `_handle_interaction(collider)`。
3. **标签匹配**：代码判断 `collider.is_in_group("enemy")` 为 `true`。
4. **触发战斗**：
   - 发送文本消息 `"MSG_HIT_ENEMY"`。
   - 抛出战斗事件：`EventBus.encounter_monster.emit(collider.monster_id, collider)`。主程序收到后，立即冻结玩家操作并进入战斗状态。

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
