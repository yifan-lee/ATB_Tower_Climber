extends Area2D

func _unhandled_input(event: InputEvent) -> void:
    var step: int = GameConfig.tile_size
    
    # 1. 我们先不直接修改位置，而是先算出一个“目标位置”
    var target_x: float = position.x
    var target_y: float = position.y
    
    if event.is_action_pressed("ui_right"):
        target_x += step
    elif event.is_action_pressed("ui_left"):
        target_x -= step
    elif event.is_action_pressed("ui_down"):
        target_y += step
    elif event.is_action_pressed("ui_up"):
        target_y -= step
        
    # 2. 计算出地图的最大边界像素 (网格数量 - 1) * 格子大小
    # 比如 5 个格子，最大索引是 4，4 * 64 = 256
    var max_pos: float = (GameConfig.grid_size - 1) * GameConfig.tile_size
    
    # 3. 施展魔法：用 clamp 函数强行把目标坐标限制在 0 和最大边界之间！
    target_x = clamp(target_x, 0, max_pos)
    target_y = clamp(target_y, 0, max_pos)
    
    # 4. 最后，把经过“安全检查”的坐标，真正赋值给主角
    position.x = target_x
    position.y = target_y

func _on_area_entered(area: Area2D) -> void:
	# 检查撞到的这个东西，有没有我们刚才贴上的 "enemy" 标签
    if area.is_in_group("enemy"):
        print("💥【系统提示】遭遇怪物！")
        print("准备调用战斗画面...")
        
        # 为了防止主角在战斗时还能乱跑，我们可以先强行关掉他的按键检测
        set_process_unhandled_input(false)
