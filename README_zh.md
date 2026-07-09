# ATB回合制爬塔RPG (ATB Tower Climber)

一款结合了 ATB（时间槽）回合制战斗机制与网格探索的轻量级 RPG 游戏。玩家需要在多层的塔中通过网格进行探索，遭遇怪物，触发基于速度属性的即时回合制战斗，获取成长奖励并最终登顶。

使用 **Godot Engine 4.7** 开发 (Mobile 渲染预设 / 2D 顶视角画面风格)。

---

## 🎮 游戏核心玩法

- **核心循环**：探索网格地图 ➔ 遭遇怪物 ➔ ATB 战斗结算 ➔ 数值养成/获得奖励 ➔ 前往下一层。
- **操作方式**：通过方向键（ui_up、ui_down、ui_left、ui_right）进行上、下、左、右网格移动。
- **画面分辨率**：复古风格的 320x320 像素视口。

---

## 🛠️ 项目结构

- **[docs/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/docs/)**：存放游戏设计与开发规范文档。
  - [GDD.md](file:///Users/yifanli/Github/game/ATB_Tower_Climber/docs/GDD.md)：详细的游戏设计文档 (Game Design Document)。
- **[core/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/core/)**：全局配置与 Autoload 单例。
  - [game_config.gd](file:///Users/yifanli/Github/game/ATB_Tower_Climber/core/game_config.gd)：定义网格大小 (5x5)、格子像素大小 (64px) 以及总层数 (3层) 等基本参数。
- **[entities/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/entities/)**：实体场景模板。
  - [player/Player.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/entities/player/Player.tscn)：挂载网格移动脚本和 RayCast2D 射线探测的玩家节点。
  - [enemies/Monster1.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/entities/enemies/Monster1.tscn)：归属于 `enemy` 组的怪物节点。
- **[scenes/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scenes/)**：场景管理与关卡文件。
  - [game.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scenes/game.tscn)：游戏根入口节点。
  - [map/world.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scenes/map/world.tscn)：当前处于探索状态的游戏世界地图。
- **[scripts/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scripts/)**：逻辑代码。
  - [player_map.gd](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scripts/player_map.gd)：处理网格移动、RayCast 碰撞判定以及遭遇怪物的战斗触发。
  - [enemy_map.gd](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scripts/enemy_map.gd)：怪物地图实体的基础配置脚本。

---

## ⚔️ 核心机制说明

### 1. 网格探索与碰撞判定
- 游戏每层为固定的 5x5 网格，实体均占据 1 个网格。
- 玩家每次仅可向四方向移动 1 格（每次位移 64 像素）。
- 在移动前会伸出 `RayCast2D` 射线，若前方的格子里有障碍物则阻挡移动，若前方为怪物，则触发战斗初始化。

### 2. ATB 战斗系统
- **速度优先 (SPD)**：战斗实体共享一个从 0 ➔ 1 的时间进度槽，根据各自的“速度 (SPD)”决定进度条的填充速率。
- **行动权结算**：进度条率先到达 1 的角色获得行动权，此时时间暂停，玩家选择技能并结算伤害。
- **伤害公式**：`实际扣除 HP = 技能伤害 * (攻击方 ATK / 防御方 DEF)`。行动结束后重置进度条为 0，时间恢复流动。

---

## 🚀 MVP 开发进度

- [x] 跑通网格地图基础显示 (5x5 像素格背景)
- [x] 玩家可通过键盘按键实现四方向移动，并支持边界限制
- [x] 绘制怪物实体，放入地图网格
- [x] 玩家碰撞怪物触发战斗初始化
- [ ] 绘制障碍物 (Wall) 并实现碰撞阻挡
- [ ] 绘制传送爬梯 (Ladder) 并实现层数切换
- [ ] 独立跑通数值 ATB 战斗场景循环 (满 1 结算扣血)
- [ ] 实现探索地图与战斗场景的衔接切换

---

## 💻 运行与开发指引

1. 下载并安装 **Godot Engine 4.7** (或兼容的 4.x 版本)。
2. 克隆本仓库到本地：
   ```bash
   git clone https://github.com/yifan-lee/ATB_Tower_Climber.git
   ```
3. 打开 Godot 编辑器，选择 **Import**，定位到该目录下的 `project.godot` 文件导入并打开项目。
4. 按下 **F5** 即可直接运行当前项目！
