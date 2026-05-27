extends Resource
class_name BattleMove

enum Target {SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF}
enum MoveCategory {OFFENSE, HEALING, STATUS, SUPPORT, UTILITY}
enum MoveTemplate {AUTO, ATTACK, HEAL, STATUS, SUPPORT, UTILITY}
enum TurnOrderManipulation {NONE, PLACE_BEFORE_ACTOR, PLACE_AFTER_ACTOR, HASTEN_TARGET, DELAY_TARGET}

@export var id: String="" # Unique identifier for the move, used for referencing in code and data structures
@export_group("Visual & Info")
@export var move_name: String = "New Move"
@export_multiline var description: String = "A new move."
@export var icon: Texture2D = null # Direct per-move texture override (highest icon priority)
@export var ui_icon_name: StringName = &"" # Optional key resolved by UIIconLibrary key map (element_*, template_*, move_*, etc.)
@export var template_mode: MoveTemplate = MoveTemplate.AUTO
@export var vfx_scene: PackedScene = null

# Target
@export var target_type: Target = Target.SINGLE_ENEMY

@export_group("Damage")
@export var power: int = 5
@export var mp_cost: int=0
@export var is_magic: bool=false
@export var element: GlobalData.Element = GlobalData.Element.NEUTRAL
@export var chance_applying_element: float = 0.0

@export var physical_type: GlobalData.PhysicalType = GlobalData.PhysicalType.NONE

@export_group("Turn Order")
@export var action_value_bonus: int = 0
@export var action_value_speed_scale: float = 10.0
@export var turn_order_manipulation: TurnOrderManipulation = TurnOrderManipulation.NONE
@export var turn_order_amount: int = 1

# Healing
@export_group("Healing & Support")
@export var heals_hp: int = 0
@export var heals_mp: int = 0
@export var cures_status: bool = false

@export_group("Status Effect")
@export var applied_status: StatusEffect = null
@export var status_chance: float = 1.0

func get_move_category() -> MoveCategory:
	if power > 0:
		return MoveCategory.OFFENSE
	if heals_hp > 0 or heals_mp > 0:
		return MoveCategory.HEALING
	if applied_status != null:
		return MoveCategory.STATUS
	if cures_status:
		return MoveCategory.SUPPORT
	return MoveCategory.UTILITY

func get_move_template() -> MoveTemplate:
	if template_mode != MoveTemplate.AUTO:
		return template_mode

	match get_move_category():
		MoveCategory.OFFENSE:
			return MoveTemplate.ATTACK
		MoveCategory.HEALING:
			return MoveTemplate.HEAL
		MoveCategory.STATUS:
			return MoveTemplate.STATUS
		MoveCategory.SUPPORT:
			return MoveTemplate.SUPPORT
		MoveCategory.UTILITY:
			return MoveTemplate.UTILITY

	return MoveTemplate.UTILITY

func get_move_template_label() -> String:
	match get_move_template():
		MoveTemplate.ATTACK:
			return "Attack Template"
		MoveTemplate.HEAL:
			return "Heal Template"
		MoveTemplate.STATUS:
			return "Status Template"
		MoveTemplate.SUPPORT:
			return "Support Template"
		MoveTemplate.UTILITY:
			return "Utility Template"
		_:
			return "Auto Template"

func get_move_category_label() -> String:
	match get_move_category():
		MoveCategory.OFFENSE:
			return "Attack"
		MoveCategory.HEALING:
			return "Heal"
		MoveCategory.STATUS:
			return "Status"
		MoveCategory.SUPPORT:
			return "Support"
		_:
			return "Utility"

func get_target_label() -> String:
	match target_type:
		Target.SINGLE_ENEMY:
			return "Single Enemy"
		Target.ALL_ENEMIES:
			return "All Enemies"
		Target.SINGLE_ALLY:
			return "Single Ally"
		Target.ALL_ALLIES:
			return "All Allies"
		Target.SELF:
			return "Self"
	return "Unknown"

func _append_icon_candidate(candidates: PackedStringArray, value: StringName) -> void:
	if value != &"" and not candidates.has(String(value)):
		candidates.append(String(value))

func get_icon_candidates() -> PackedStringArray:
	var candidates: PackedStringArray = PackedStringArray()

	_append_icon_candidate(candidates, ui_icon_name)

	if icon != null:
		_append_icon_candidate(candidates, &"custom_texture")

	var template_key: String = "template_%s" % get_move_template_label().to_lower().replace(" ", "_")
	_append_icon_candidate(candidates, StringName(template_key))

	var category_key: String = "move_%s" % get_move_category_label().to_lower().replace(" ", "_")
	_append_icon_candidate(candidates, StringName(category_key))

	if is_magic and element != GlobalData.Element.NEUTRAL:
		var element_key: String = "element_%s" % GlobalData.Element.keys()[element].to_lower()
		_append_icon_candidate(candidates, StringName(element_key))
	elif not is_magic and physical_type != GlobalData.PhysicalType.NONE:
		var physical_key: String = "physical_%s" % GlobalData.PhysicalType.keys()[physical_type].to_lower()
		_append_icon_candidate(candidates, StringName(physical_key))

	match target_type:
		Target.ALL_ENEMIES, Target.ALL_ALLIES:
			_append_icon_candidate(candidates, &"target_aoe")
		Target.SELF:
			_append_icon_candidate(candidates, &"target_self")

	return candidates

func get_icon_key() -> StringName:
	var candidates := get_icon_candidates()
	if candidates.size() > 0:
		return StringName(candidates[0])
	return &""

func get_placeholder_icon_name() -> StringName:
	if ui_icon_name != &"":
		return ui_icon_name

	match get_move_template():
		MoveTemplate.ATTACK:
			if target_type == Target.ALL_ENEMIES or target_type == Target.ALL_ALLIES:
				return &"Group"
			if is_magic:
				# All magic elements use the generic magic icon
				return &"ColorRect"
			return &"Sword"
		MoveTemplate.HEAL:
			return &"Heal"
		MoveTemplate.STATUS:
			if applied_status != null and applied_status.effect_type == StatusEffect.Type.BUFF:
				return &"Buff"
			return &"Debuff"
		MoveTemplate.SUPPORT:
			return &"Heal"
		MoveTemplate.UTILITY:
			return &"Node"
		_:
			return &"Node"

func get_icon_tags() -> PackedStringArray:
	return get_icon_candidates()

func get_button_label() -> String:
	var label_parts: PackedStringArray = PackedStringArray()
	label_parts.append(get_move_template_label())
	label_parts.append(get_target_label())

	if is_magic and element != GlobalData.Element.NEUTRAL:
		label_parts.append(GlobalData.Element.keys()[element].capitalize())
	elif not is_magic and physical_type != GlobalData.PhysicalType.NONE:
		label_parts.append(GlobalData.PhysicalType.keys()[physical_type].capitalize())

	return "%s [%s]" % [move_name, ", ".join(label_parts)]

func get_action_value(attacker: Battler = null) -> int:
	var speed_component: float = 0.0
	if attacker != null and attacker.stats_manager != null:
		speed_component = float(attacker.stats_manager.get_active_speed()) * action_value_speed_scale

	return max(1, roundi(speed_component + float(action_value_bonus)))
