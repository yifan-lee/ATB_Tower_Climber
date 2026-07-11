extends Resource
class_name SkillData # 极其重要：这让 Godot 认识这个新类型

@export var skill_name: String = "技能名称"
@export var damage_bonus: int = 0
@export var max_cd: int = 0