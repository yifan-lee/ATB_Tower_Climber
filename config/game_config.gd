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


# ==========================================
# 全局工具函数：自动按目标尺寸缩放生成动画精灵
# ==========================================
func create_scaled_anim_sprite(anim_path: String, target_size: float = GRID_SIZE, anim_name: String = "idle") -> AnimatedSprite2D:
	var anim = AnimatedSprite2D.new()
	anim.sprite_frames = load(anim_path)
	
	# 读取指定动画第一帧的原始纹理大小
	var texture = anim.sprite_frames.get_frame_texture(anim_name, 0)
	if texture != null:
		var original_size = texture.get_size()
		# 自动计算缩放比例（例如 64 / 16 = 4）
		anim.scale = Vector2(target_size / original_size.x, target_size / original_size.y)
	
	anim.play(anim_name)
	return anim