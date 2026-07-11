# res://ui/info_panel.gd
extends ColorRect

func _ready():
    # 强制设置尺寸为 320x160，适配下方的展示区域
    self.size = Vector2(GameConfig.SCREEN_WIDTH, GameConfig.INFO_AREA_HEIGHT)
    # 设置一个深灰色的背景作为占位
    self.color = Color(0.15, 0.15, 0.15)