extends Area2D # 声明：这个脚本是挂载在 Area2D 节点上的

@onready var ray: RayCast2D = $RayCast2D # 绑定：在游戏启动时，自动找到子节点里的 RayCast2D 并赋值给变量 ray

func _unhandled_input(event: InputEvent) -> void: # 事件：这是 Godot 内置函数，只要有按键按下就会触发
	var move_dir: Vector2 = Vector2.ZERO # 初始化：准备一个变量来存玩家想移动的方向，默认为不动
	
	# 判断：检测玩家按下了哪个键，并把 move_dir 设置为对应的方向向量
	move_dir = _decide_movement_direction(event)

	# 检测：如果玩家确实按下了某个方向键
	if move_dir != Vector2.ZERO:
		_decide_move_result(move_dir)

func _decide_movement_direction(event: InputEvent) -> Vector2:
	var step: int = GameConfig.tile_size # 读取：从全局配置中心获取格子像素大小 (64)
	var move_dir: Vector2 = Vector2.ZERO # 初始化：准备一个变量来存玩家想移动的方向，默认为不动

	# 判断：检测玩家按下了哪个键，并把 move_dir 设置为对应的方向向量
	if event.is_action_pressed("ui_right"): move_dir = Vector2.RIGHT * step
	elif event.is_action_pressed("ui_left"): move_dir = Vector2.LEFT * step
	elif event.is_action_pressed("ui_down"): move_dir = Vector2.DOWN * step
	elif event.is_action_pressed("ui_up"): move_dir = Vector2.UP * step

	return move_dir


func _decide_move_result(move_dir: Vector2) -> void:
	ray.target_position = move_dir # 伸出拐杖：把射线的目标点设置在你想要去的方向
	ray.force_raycast_update() # 强制刷新：告诉引擎“现在就检测一次”，不要等下一帧
	
	# 判断拐杖结果：is_colliding() 返回 true 代表探测到了东西
	if ray.is_colliding():
		_decide_colliding_result()
	else:
		_execute_move(move_dir)
		

func _decide_colliding_result() -> void:
	var collider = ray.get_collider() # 获取对象：看看射线碰到的是谁？
	if collider.is_in_group("enemy"): # 分类：如果是怪物组的成员
		print("撞到了怪物！触发战斗！")
		trigger_battle() # 执行：触发战斗函数
	elif collider.is_in_group("wall"):
		print("前方有障碍物，无法通过！")
	elif collider.is_in_group("stairs") and collider.is_active:
		# 呼叫父节点 (Game) 换楼层，直接传楼层号，不需要传坐标！
		get_parent().change_floor(collider.target_floor)
		return # 终止本次移动逻辑
	else:
		print("不知道是什么，过不去！") # 阻挡：如果是墙壁或其它，不移动


func trigger_battle(): # 定义战斗：在这里处理战斗切换逻辑
	# set_process_unhandled_input(false) # 锁定输入：战斗时禁止玩家乱走
	print("战斗初始化中...")

func _execute_move(move_dir: Vector2) -> void:
	# 执行移动：如果前面什么都没碰到，执行坐标偏移
	var max_pos: float = (GameConfig.grid_size - 1) * GameConfig.tile_size
	position.x = clamp(position.x + move_dir.x, 0, max_pos)
	position.y = clamp(position.y + move_dir.y, 0, max_pos)
