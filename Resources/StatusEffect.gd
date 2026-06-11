@tool
extends Resource
class_name StatusEffect

enum Type { BUFF, DEBUFF, CROWD_CONTROL}

@export var id: String = ""
@export var effect_name: String = ""
@export_multiline var description: String = ""
@export var effect_type: Type = Type.DEBUFF
@export var duration_turns: int = 1

@export var is_conductive: bool = false # For reactions that can jump to nearby targets, like Shock
@export var decay_per_jump: float = 0.0 # For conductive reactions, how much the effect weakens with each jump
@export var base_stun_chance: float = 0.0 # For conductive reactions, the chance to stun on each jump

@export_group("Damage & Healing Over Time")
@export var dot_dmg: int = 0
@export var heals_lowest_ally_per_turn: int = 0
@export var down_meter_fill_per_turn: int = 0

@export_group("Stat Modifiers (Percentages)")
# Use decimals! e.g., 0.5 is +50% Buff, -0.3 is -30% Debuff
@export var stat_mult_strength: float = 0.0
@export var stat_mult_magic: float = 0.0
@export var stat_mult_defense: float = 0.0
@export var stat_mult_speed: float = 0.0
@export var stat_mult_accuracy: float = 0.0
@export var stat_mult_crit_chance: float = 0.0
@export var stat_mult_crit_dmg: float = 0.0
@export var stat_mult_down_meter_fill: float = 0.0

@export_group("Combat Locks & Overrides")
@export var is_stunned: bool = false # Skips turn
@export var locks_magic: bool = false
@export var locks_physical: bool = false
@export var disables_healing: bool = false
@export var sets_defense_to_zero: bool = false
@export var flips_weaknesses: bool = false

@export_group("Combo & Reaction Triggers")
@export var is_chain_reaction: bool = false
@export var reaction_primer: int = 0
@export var reaction_trigger: int = 0
# Each entry is Vector2i(primer, trigger) using GlobalData.Element enum values.
# This allows one reaction to be triggered by multiple recipes (useful for ascended variants).
@export var reaction_recipes: Array[Vector2i] = []
@export var refresh_recipe_preview: bool = false:
    set(value):
        if value:
            rebuild_reaction_recipe_preview()
        refresh_recipe_preview = false
@export_multiline var reaction_recipe_preview: String = ""
@export var damage_scales_with_debuffs: bool = false
@export var clears_all_statuses: bool = false
@export var guarantees_next_crit: bool = false
@export var reaction_burst_mult: float = 1.0

@export_group("AOE & Targeting")
@export var applies_to_all_enemies: bool = false
@export var applies_to_all_allies: bool = false
@export var affects_both_parties: bool = false

@export_group("Friendly Fire & Target Manipulation")
# Chance (0.0-1.0) that the target will attack allies instead (or cause friendly-fire behavior)
@export var chance_friendly_fire: float = 0.0

@export_group("Interactions & Flags")
# Heal MP amount applied to attacker when effect triggers
@export var heal_attacker_mp: int = 0

@export_group("Niche Effects")
@export var removes_on_physical_hit: bool = false
@export var removes_on_magic_hit: bool = false

# --- FUTURE: Ascended & Advanced Effects (Planned) ---
# Uncomment and wire these when implementing advanced chain reactions and Ascended mechanics.
# @export var disables_dodge: bool = false
# @export var changes_turn_queue: bool = false
# @export var spreads_radium_on_down: bool = false
# @export var spreads_when_down: bool = false
# @export var spreads_on_down_to_party: bool = false
# @export var forces_target_change: bool = false
# @export var shuffles_turn_order: bool = false
# @export var is_aoe: bool = false
# @export var affects_self_and_targets: bool = false
# @export var is_weaken_down_meter: bool = false
# @export var scales_with_debuffs: bool = false (NOTE: use damage_scales_with_debuffs instead)
# @export var removes_buffs: bool = false
# @export var add_random_nerfs: int = 0
# @export var mp_steal_amount: int = 0
# @export var ignores_def: bool = false
# @export var flip_all_resistances: bool = false (NOTE: use flips_weaknesses instead)
# @export var true_damage_multiplier: float = 1.0
# @export var is_true_damage: bool = false
# @export var steals_stats: bool = false

func matches_reaction_recipe(primer: int, trigger: int) -> bool:
    if not is_chain_reaction:
        return false

    # New path: support multiple recipes per reaction resource.
    for recipe in reaction_recipes:
        if (recipe.x == primer and recipe.y == trigger) or (recipe.x == trigger and recipe.y == primer):
            return true

    # Backward compatibility: old single-pair fields still work.
    return (reaction_primer == primer and reaction_trigger == trigger) or (reaction_primer == trigger and reaction_trigger == primer)

func rebuild_reaction_recipe_preview() -> void:
    var lines: PackedStringArray = []

    for recipe in reaction_recipes:
        lines.append(_format_recipe_line(recipe.x, recipe.y))

    # Show legacy single-pair recipe too, so old data is still visible while editing.
    if reaction_primer != 0 or reaction_trigger != 0:
        lines.append("legacy: " + _format_recipe_line(reaction_primer, reaction_trigger))

    if lines.is_empty():
        reaction_recipe_preview = "No recipes configured."
    else:
        reaction_recipe_preview = "\n".join(lines)

func _format_recipe_line(primer: int, trigger: int) -> String:
    return _element_name(primer) + " + " + _element_name(trigger)

func _element_name(value: int) -> String:
    var names: PackedStringArray = GlobalData.Element.keys()
    if value >= 0 and value < names.size():
        return names[value]
    return "UNKNOWN(" + str(value) + ")"
