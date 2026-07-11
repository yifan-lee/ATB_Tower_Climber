extends Node

# 1. 预载入一楼的场景文件（请根据你项目里的实际路径修改，如 "res://scenes/Map/Floor_1.tscn"）
var floor_1_scene = preload("res://scenes/Map/Floor_1.tscn")

# 2. 用来存储当前加载的地图节点引用
var current_floor_node: Node = null

# 3. 自动绑定平级的主角节点
@onready var player: Area2D = $Player

func _ready() -> void:
	# --- 第一步：把一楼实例化并塞进舞台 ---
	current_floor_node = floor_1_scene.instantiate()
	add_child(current_floor_node)
	
	# --- 第二步：让 Player 在一楼的正确位置出生 ---
	# 假设你想让主角出生在一楼的 (64, 64) 或者是 (0, 0) 格子
	# 如果想让他在某个特定网格（比如第3行第2列），坐标就是 Vector2(3 * 64, 2 * 64)
	var spawn_grid_pos: Vector2 = Vector2(2, 4)
	
	# 将格子坐标转换为实际像素坐标，并赋予 Player
	player.position = spawn_grid_pos * GameConfig.tile_size
	
	print("✨ [架构就绪] 一楼地图加载成功，Player 已安全送达一楼初始位置：", player.position)


func change_floor(floor_num: int):
	# 1. 抽走旧桌布 (销毁旧楼层)
	if current_floor_node:
		current_floor_node.queue_free()
		
	# 2. 铺上新桌布 (加载新楼层)
	var floor_path = "res://scenes/Map/Floor_" + str(floor_num) + ".tscn"
	var new_floor = load(floor_path).instantiate()
	
	# 3. 放到场景里，并用 move_child 把它垫底，防止盖住主角
	add_child(new_floor)
	move_child(new_floor, 0)
	current_floor_node = new_floor
	
	# 主角在哪？主角原地没动！完美契合你的需求！
