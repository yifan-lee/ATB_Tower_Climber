# 在 config/game_config.gd 中
extends Node


# 网格系统设定
const GRID_SIZE: int = 64
const GRID_COLUMNS: int = 5 # 320 / 64
const GRID_ROWS: int = 5 # 320 / 64
const WALL_THICKNESS: int = 0


# 屏幕尺寸设定

const SCREEN_RATIO: float = 16.0 / 9.0
const SCREEN_WIDTH: int = GRID_COLUMNS * GRID_SIZE + WALL_THICKNESS * 2
const SCREEN_HEIGHT: int = SCREEN_WIDTH * SCREEN_RATIO
const EXPLORE_AREA_HEIGHT: int = GRID_ROWS * GRID_SIZE + WALL_THICKNESS * 2
const INFO_AREA_HEIGHT: int = SCREEN_HEIGHT - EXPLORE_AREA_HEIGHT

# 塔的总层数 (N)
const MAX_FLOOR: int = 3