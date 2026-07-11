extends Resource
class_name CharacterStats # 注册角色数据类型

@export var character_name: String = "角色名称"
@export var max_hp: float = 500
@export var current_hp: float = 500
@export var atk: float = 100
@export var def: float = 100
@export var spd: float = 100
@export var texture: SpriteFrames # 完美解决贴图需求！可以直接拖入PNG
@export var base_attack_damage: float = 0
@export var skills: Array[SkillData] = [] # 技能列表，专门存放上面定义的 SkillData