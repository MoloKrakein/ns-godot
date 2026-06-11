extends Resource
class_name BattlerStats

enum Affinity {WEAK, NORMAL, RESIST, BLOCK}
@export var id: String = "enm_monster"
@export var character_name: String = "Monster"
@export var element: GlobalData.Element = GlobalData.Element.NEUTRAL

@export_group("Affinities")
@export var elemental_affinities: Array[ElementAffinityEntry] = []
@export var physical_affinity: BattlerStats.Affinity = BattlerStats.Affinity.NORMAL

func get_elemental_affinity(element_type: GlobalData.Element) -> Affinity:
    for entry in elemental_affinities:
        if entry != null and entry.element == element_type:
            return entry.affinity
    return Affinity.NORMAL

func get_physical_affinity(physical_type: GlobalData.PhysicalType) -> Affinity:
    # Physical type is consolidated; return the single configured physical affinity.
    return physical_affinity

func get_elemental_affinity_map() -> Dictionary:
    var result: Dictionary = {}
    for entry in elemental_affinities:
        if entry != null:
            result[entry.element] = entry.affinity
    return result

func get_physical_affinity_map() -> Dictionary:
    var result: Dictionary = {}
    # Map the consolidated physical affinity to the PHYSICAL enum key
    result[GlobalData.PhysicalType.PHYSICAL] = physical_affinity
    return result

@export_group("Base Stats")
@export var max_hp: int = 50
@export var max_mp: int = 20
@export var speed: int = 10

@export_group("Offense")
@export var strength: int = 10
@export var magic: int = 10

@export_group("Defense")
@export var physical_def: int = 5
@export var magic_def: int = 5

@export_group("Crit")
@export var luck: int = 5
@export var crit_rate: float = 0.0
@export var crit_dmg: float = 0.0

