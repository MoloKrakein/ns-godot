extends Node
class_name AffinityManager

@onready var battler: Battler = get_parent() as Battler

var temporary_elemental_overrides: Dictionary = {}
var temporary_physical_overrides: Dictionary = {}

func get_base_affinity(is_magic: bool, element: GlobalData.Element = GlobalData.Element.NEUTRAL, phys_type: GlobalData.PhysicalType = GlobalData.PhysicalType.NONE) -> BattlerStats.Affinity:
	if battler == null or battler.stats == null:
		return BattlerStats.Affinity.NORMAL
	if is_magic:
		return battler.stats.get_elemental_affinity(element)
	return battler.stats.get_physical_affinity(phys_type)

func get_current_affinity(is_magic: bool, element: GlobalData.Element = GlobalData.Element.NEUTRAL, phys_type: GlobalData.PhysicalType = GlobalData.PhysicalType.NONE) -> BattlerStats.Affinity:
	var affinity: BattlerStats.Affinity = get_base_affinity(is_magic, element, phys_type)

	if is_magic and temporary_elemental_overrides.has(element):
		affinity = temporary_elemental_overrides[element]
	elif not is_magic and temporary_physical_overrides.has(phys_type):
		affinity = temporary_physical_overrides[phys_type]

	if battler != null and battler.status_manager != null and battler.status_manager.has_flipped_weakness():
		affinity = _flip_affinity(affinity)

	return affinity

func get_damage_multiplier(is_magic: bool, element: GlobalData.Element = GlobalData.Element.NEUTRAL, phys_type: GlobalData.PhysicalType = GlobalData.PhysicalType.NONE) -> float:
	match get_current_affinity(is_magic, element, phys_type):
		BattlerStats.Affinity.WEAK:
			return 2.0
		BattlerStats.Affinity.NORMAL:
			return 1.0
		BattlerStats.Affinity.RESIST:
			return 0.6
		BattlerStats.Affinity.BLOCK:
			return 0.0
		_:
			return 1.0

func is_weakness_hit(is_magic: bool, element: GlobalData.Element = GlobalData.Element.NEUTRAL, phys_type: GlobalData.PhysicalType = GlobalData.PhysicalType.NONE) -> bool:
	return get_current_affinity(is_magic, element, phys_type) == BattlerStats.Affinity.WEAK

func is_blocked(is_magic: bool, element: GlobalData.Element = GlobalData.Element.NEUTRAL, phys_type: GlobalData.PhysicalType = GlobalData.PhysicalType.NONE) -> bool:
	return get_current_affinity(is_magic, element, phys_type) == BattlerStats.Affinity.BLOCK

func set_element_override(element: GlobalData.Element, affinity: BattlerStats.Affinity) -> void:
	temporary_elemental_overrides[element] = affinity

func set_physical_override(phys_type: GlobalData.PhysicalType, affinity: BattlerStats.Affinity) -> void:
	temporary_physical_overrides[phys_type] = affinity

func clear_overrides() -> void:
	temporary_elemental_overrides.clear()
	temporary_physical_overrides.clear()

func get_elemental_affinity_map() -> Dictionary:
	if battler == null or battler.stats == null:
		return {}
	var result: Dictionary = {}
	for element_name in GlobalData.Element.keys():
		var element_value: GlobalData.Element = GlobalData.Element[element_name]
		result[element_value] = get_current_affinity(true, element_value, GlobalData.PhysicalType.NONE)
	return result

func get_physical_affinity_map() -> Dictionary:
	if battler == null or battler.stats == null:
		return {}
	var result: Dictionary = {}
	for phys_name in GlobalData.PhysicalType.keys():
		var phys_value: GlobalData.PhysicalType = GlobalData.PhysicalType[phys_name]
		result[phys_value] = get_current_affinity(false, GlobalData.Element.NEUTRAL, phys_value)
	return result

func _flip_affinity(affinity: BattlerStats.Affinity) -> BattlerStats.Affinity:
	match affinity:
		BattlerStats.Affinity.WEAK:
			return BattlerStats.Affinity.RESIST
		BattlerStats.Affinity.RESIST:
			return BattlerStats.Affinity.WEAK
		BattlerStats.Affinity.BLOCK:
			return BattlerStats.Affinity.NORMAL
		BattlerStats.Affinity.NORMAL:
			return BattlerStats.Affinity.NORMAL
		_:
			return BattlerStats.Affinity.NORMAL
