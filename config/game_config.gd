# 在 config/game_config.gd 中
extends Node


# 网格系统设定
const GRID_SIZE: int = 64
const GRID_COLUMNS: int = 9 # 320 / 64
const GRID_ROWS: int = 9 # 320 / 64
const WALL_THICKNESS: int = 32


# 屏幕尺寸设定

const SCREEN_RATIO: float = 16.0 / 9.0
const SCREEN_WIDTH: int = GRID_COLUMNS * GRID_SIZE + WALL_THICKNESS * 2
const SCREEN_HEIGHT: int = SCREEN_WIDTH * SCREEN_RATIO
const GAME_AREA_HEIGHT: int = GRID_ROWS * GRID_SIZE + WALL_THICKNESS * 2
const UI_AREA_HEIGHT: int = SCREEN_HEIGHT - GAME_AREA_HEIGHT

# 塔的总层数 (N)
const MAX_FLOOR: int = 3

# 控制设置
# 如果为 true，则使用 WASD 移动；如果为 false，则使用方向键移动
var use_wasd_movement: bool = true


# ==========================================
# 全局工具函数
# ==========================================

# 将网格坐标转换为屏幕实际像素坐标（中心点）
func get_game_area_pixel_position(grid_x: int, grid_y: int) -> Vector2:
	var pixel_x = grid_x * GRID_SIZE + (GRID_SIZE / 2.0) + WALL_THICKNESS
	var pixel_y = grid_y * GRID_SIZE + (GRID_SIZE / 2.0) + WALL_THICKNESS
	return Vector2(pixel_x, pixel_y)

func get_ui_area_pixel_position(grid_x: int, grid_y: int) -> Vector2:
	var pixel_x = grid_x * GRID_SIZE + (GRID_SIZE / 2.0) + WALL_THICKNESS
	var pixel_y = grid_y * GRID_SIZE + (GRID_SIZE / 2.0) + GAME_AREA_HEIGHT
	return Vector2(pixel_x, pixel_y)

# 将屏幕实际像素坐标转换为网格坐标
func get_grid_position(pixel_pos: Vector2) -> Vector2i:
	var grid_x = int((pixel_pos.x - WALL_THICKNESS) / GRID_SIZE)
	var grid_y = int((pixel_pos.y - WALL_THICKNESS) / GRID_SIZE)
	return Vector2i(grid_x, grid_y)

# 输入检测辅助函数
func is_action_move_up(event: InputEvent) -> bool:
	if use_wasd_movement:
		return event is InputEventKey and event.keycode == KEY_W and event.pressed and not event.echo
	else:
		return event.is_action_pressed("ui_up") or (event is InputEventKey and event.keycode == KEY_UP and event.pressed and not event.echo)

func is_action_move_down(event: InputEvent) -> bool:
	if use_wasd_movement:
		return event is InputEventKey and event.keycode == KEY_S and event.pressed and not event.echo
	else:
		return event.is_action_pressed("ui_down") or (event is InputEventKey and event.keycode == KEY_DOWN and event.pressed and not event.echo)

func is_action_move_left(event: InputEvent) -> bool:
	if use_wasd_movement:
		return event is InputEventKey and event.keycode == KEY_A and event.pressed and not event.echo
	else:
		return event.is_action_pressed("ui_left") or (event is InputEventKey and event.keycode == KEY_LEFT and event.pressed and not event.echo)

func is_action_move_right(event: InputEvent) -> bool:
	if use_wasd_movement:
		return event is InputEventKey and event.keycode == KEY_D and event.pressed and not event.echo
	else:
		return event.is_action_pressed("ui_right") or (event is InputEventKey and event.keycode == KEY_RIGHT and event.pressed and not event.echo)

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