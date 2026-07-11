extends Area2D

@export var target_floor: int = 1 # 在检查器里填你想去哪层
var is_active: bool = false # 状态锁

func _ready():
    add_to_group("stairs")
    # 魔法在此：新楼层加载时，楼梯在头 0.2 秒内是“死”的。
    # 这样就算主角和它重叠，也不会瞬间触发传送回来。
    await get_tree().create_timer(0.2).timeout
    is_active = true