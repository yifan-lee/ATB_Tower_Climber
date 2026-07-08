extends Node

# 声明变量：进度条当前值和角色的速度
var atb_progress: float = 0.0
var speed: float = 25.0

# 新加这个函数！它会在游戏运行的第 0.1 秒立刻触发
func _ready() -> void:
	print("【系统提示】引擎点火成功！游戏开始运行！")

# _process 是 Godot 的内置函数，每一帧都会执行
func _process(delta: float) -> void:
	# 核心逻辑：进度 = 速度 * 帧间隔时间 (delta)
	atb_progress += speed * delta
	
	# 检查进度条是否满 100
	if atb_progress >= 100.0:
		print("【系统提示】进度条已满 100，当前角色可以行动！")
		
		# 暂停该角色的进度条，等待玩家输入指令 (这里先简单重置为 0)
		atb_progress = 0.0
