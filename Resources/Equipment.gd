extends Resource

class_name Equipment

enum Slot { WEAPON, ARMOR, SHOE, NECKTIE, PANTS, ACCESSORY }

@export var id: String = "" #wpn_starter_sword
@export var equip_name: String = "Mock up Sword"
@export var equip_desc: String = "Training Sword for Beginner"
@export var slot_type: Slot = Slot.WEAPON
# @export var attack_type: GlobalData.PhysicalType = GlobalData.PhysicalType.SLASH
@export var weapon_attack_move: BattleMove

@export var set_family: String = "None"

@export_group("Stat Bonuses")
@export var bonus_max_hp:int = 0
@export var bonus_strength:int = 0
@export var bonus_magic:int = 0
@export var bonus_physical_def:int = 0
@export var bonus_magic_def:int = 0
@export var bonus_luck:int=0
@export var bonus_speed:int=0

@export_group("Crit Bonuses")
@export var bonus_crit_rate:float= 0.0
@export var bonus_crit_dmg:float= 0.0

@export_group("Firearm")
@export var ammo:int = 0
@export var bullet_type:GlobalData.Element = GlobalData.Element.NEUTRAL

