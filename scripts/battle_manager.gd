extends Control
class_name BattleManager

# --- UI 节点引用 ---
@export var timeline_track: ColorRect # 跑道节点
var icon_prefab: PackedScene = preload("res://scenes/battle/unit_icon.tscn") # 修正大小写为 unit_icon.tscn

# --- 战斗状态数据 ---
var is_battle_paused: bool = false
var combatants: Array = []
var unit_icons: Dictionary = {} # 字典：记录【角色数据】对应【哪个UI图标】

# --- 内部数据结构：包装单个战斗人员 ---
class BattleUnit:
	var stats_resource: CharacterStats # 原始的 .tres 数据
	var current_hp: int
	var atb_value: float = 0.0 # 当前进度条值 (0.0 到 1.0)
	var is_player: bool = false
	
	func _init(stats: CharacterStats, player_flag: bool):
		stats_resource = stats
		current_hp = stats.max_hp
		is_player = player_flag

func _ready() -> void:
	print("【战斗系统】初始化战斗舞台...")
	setup_battle()

# 准备数据与生成 UI
func setup_battle():
	# 1. 模拟加载双方数据 (实际开发中由大地图触发时传入)
	var player_stats = load("res://resources/roles/player.tres")
	var goblin_stats = load("res://resources/roles/bloodshot_eye.tres")
	
	if player_stats: combatants.append(BattleUnit.new(player_stats, true))
	if goblin_stats: combatants.append(BattleUnit.new(goblin_stats, false))
	
	# 2. 为每个参战者生成一个小图标并放到跑道上
	for unit in combatants:
		var new_icon = icon_prefab.instantiate() as TextureRect
		timeline_track.add_child(new_icon)
		
		# 检查贴图资源类型并进行正确赋值
		if unit.stats_resource.texture:
			var tex_res = unit.stats_resource.texture
			if tex_res is SpriteFrames:
				# 如果是 SpriteFrames，提取其 idle 或第一个动画的第一帧作为图标贴图
				var anims = tex_res.get_animation_names()
				if anims.size() > 0:
					var anim_name = "idle"
					if not tex_res.has_animation(anim_name):
						anim_name = anims[0] # 找不到 idle 则默认使用第一个动画
					if tex_res.get_frame_count(anim_name) > 0:
						new_icon.texture = tex_res.get_frame_texture(anim_name, 0)
			elif tex_res is Texture2D:
				new_icon.texture = tex_res
			
		# 把这个单位和它的 UI 图标绑定起来
		unit_icons[unit] = new_icon
		
	is_battle_paused = false
	print("【战斗系统】全员准备就绪，时间开始流动！")

# 核心齿轮与 UI 更新
func _process(delta: float) -> void:
	if is_battle_paused: return
		
	var track_width = timeline_track.size.x
		
	for unit in combatants:
		# 计算每秒增加的进度比率 
		var speed: int = unit.stats_resource.spd
		var atb_gain_rate: float = (100.0 + speed) / 400.0
		
		# 累加进度
		unit.atb_value += atb_gain_rate * delta
		
		# --- 更新 UI 位置 ---
		var icon_node = unit_icons[unit]
		icon_node.position.x = unit.atb_value * track_width
		icon_node.position.y = - (icon_node.size.y / 2.0) + (timeline_track.size.y / 2.0) # 垂直居中
		
		# 检查是否触线
		if unit.atb_value >= 1.0:
			unit.atb_value = 1.0
			# 确保UI精准停在终点
			icon_node.position.x = track_width
			trigger_turn(unit)
			break # 防止同一帧多人行动冲突

# 触发回合
func trigger_turn(active_unit: BattleUnit):
	is_battle_paused = true # 暂停时间
	print("\n========================================")
	print("【行动宣告】 轮到 [%s] 的回合了！" % active_unit.stats_resource.character_name)
	
	if active_unit.is_player:
		print("【玩家回合】 等待选择技能...")
		simulate_action(active_unit) # 暂时用模拟代码跳过
	else:
		print("【怪物 AI】 自动攻击...")
		simulate_action(active_unit)

# 模拟行动并结束回合
func simulate_action(unit: BattleUnit):
	# 模拟停顿1秒钟表示正在行动，然后恢复进度
	await get_tree().create_timer(1.0).timeout
	
	unit.atb_value = 0.0 # 进度清零
	var icon_node = unit_icons[unit]
	icon_node.position.x = 0 # UI回退到起点
	
	is_battle_paused = false # 恢复时间流动
	print("【战斗系统】行动结束，时间继续流动...\n========================================")