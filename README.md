# ATB Tower Climber

A lightweight grid-based RPG combining active time battle (ATB) mechanisms. Players move step-by-step on grid-based maps across multiple floors, encounter monsters, engage in speed-based turn battle, collect rewards, and aim to reach the top of the tower.

Built with **Godot Engine 4.7** (Mobile preset / 2D top-down visual style).

---

## 🎮 Game Overview

- **Core Loop**: Grid Map Exploration ➔ Encounter Monsters ➔ ATB Combat ➔ Numerical Growth / Rewards ➔ Proceed to Next Floor.
- **Controls**: Move Up/Down/Left/Right using the Arrow keys or standard Godot input settings.
- **Visuals**: Retro-style scaled viewport (320x320 pixels).

---

## 🛠️ Project Structure

- **[docs/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/docs/)**: Contains the [Game Design Document (GDD)](file:///Users/yifanli/Github/game/ATB_Tower_Climber/docs/GDD.md) detailing rules and specifications.
- **[core/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/core/)**: Global configurations and singleton autoloads.
  - [game_config.gd](file:///Users/yifanli/Github/game/ATB_Tower_Climber/core/game_config.gd): Grid size (5x5), tile size (64px), max floors (3).
- **[entities/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/entities/)**: Scene templates for game entities.
  - [player/Player.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/entities/player/Player.tscn): Player node equipped with raycasting for movement checks and combat triggers.
  - [enemies/Monster1.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/entities/enemies/Monster1.tscn): Enemy node belonging to the `enemy` group.
- **[scenes/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scenes/)**: Game maps and stage management.
  - [game.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scenes/game.tscn): Root entry point.
  - [map/world.tscn](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scenes/map/world.tscn): The active exploration level.
- **[scripts/](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scripts/)**: GDScripts containing logic.
  - [player_map.gd](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scripts/player_map.gd): Controls grid movement and checks collisions using `RayCast2D`.
  - [enemy_map.gd](file:///Users/yifanli/Github/game/ATB_Tower_Climber/scripts/enemy_map.gd): Basic configuration for mapping enemies.

---

## ⚔️ Key Mechanisms

### 1. Grid Movement & Collisions
- Standard 5x5 grid per level. Entities occupy 1 grid cell.
- Movement is restricted to up, down, left, right directions by 64px increments.
- Utilizes `RayCast2D` to probe the next tile. If a wall or barrier is ahead, movement is blocked. If an enemy is ahead, combat is triggered.

### 2. Active Time Battle (ATB) Combat System
- **Speed (SPD) Priority**: Characters and enemies share an ATB timeline (progress 0 ➔ 1).
- **Action Turns**: The timeline fills according to each entity's SPD stat. The first one to reach 1 pauses the timeline and takes an action.
- **Combat Logic**: Damage formula: `Damage = Skill Power * (Attacker ATK / Defender DEF)`. Once actions resolve, the pointer resets to 0, and time resumes.

---

## 🚀 MVP Roadmap

- [x] Basic Grid Map setup (5x5 map grid)
- [x] Player movement with Arrow Keys/WASD and boundaries clamp
- [x] Enemy spawning and grid collision checking
- [x] Encountering enemies triggers battle initialization
- [ ] Obstacles / Walls rendering and blocking
- [ ] Ladders / stairs for level transition
- [ ] Implement standalone numerical ATB combat loop
- [ ] Connect exploration maps with the combat scene

---

## 💻 Getting Started

1. Download and install **Godot Engine 4.7** (or compatible 4.x versions).
2. Clone this repository:
   ```bash
   git clone https://github.com/yifan-lee/ATB_Tower_Climber.git
   ```
3. Open Godot Engine, click **Import**, select `project.godot` inside this directory, and click **Import & Edit**.
4. Press **F5** to run the game scene!
