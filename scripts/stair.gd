extends Area2D

# 允许在编辑器里为每个楼梯配置不同的目标
@export var target_floor: int = 1 # 要去第几层
@export var spawn_pos: Vector2 = Vector2(0, 0) # 到了之后出生在第几个格子

# 这一步很关键：当 Player 的碰撞盒接触到 Area2D 时自动触发
func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.name == "Player":
        print("🪜 触发楼梯！目标楼层：", target_floor)
        # 调用大管家切换楼层
        get_node("/root/Game").change_floor(target_floor, spawn_pos)