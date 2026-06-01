extends CharacterBody2D
class_name Battler

signal health_changed(new_hp)
signal mana_changed(new_mp)
signal downed(battler)
signal request_ally_heal(amount: int, is_enemy: bool)
signal request_item_broadcast(item: Consumable, scope: int)
signal damage_taken(amount: int, is_crit: bool, is_weakness: bool)
signal damage_resolved(amount: int, current_hp: int, max_hp: int, down_meter: int, is_weakness: bool, is_crit: bool, is_resist: bool, is_block: bool, attacker: Battler)
signal adrenaline_changed(is_active: bool, stacks: int)
signal threat_changed(value: int)
signal primer_changed(new_primer: int)
signal ui_state_changed

#region Exports
@export var stats: BattlerStats
@export var basic_atk: BattleMove
@export var skills_list: Array[BattleMove] = []

# Equipment
@export var equipped_weapon: Equipment
@export var equipped_armor: Equipment
@export var equipped_accessory: Equipment
@export var equipped_necktie: Equipment
@export var equipped_shoe: Equipment
@export var equipped_pant: Equipment
@export var equipped_moves: Array[BattleMove] = [] # Player-selected moves (max 5 recommended)
#endregion

#region Runtime State
@onready var stats_manager: StatsManager = $StatsManager
@onready var status_manager: StatusManager = $StatusManager
@onready var affinity_manager: AffinityManager = $AffinityManager
@onready var down_manager: DownManager = $DownManager

var current_hp: int
var current_mp: int
var is_down: bool
var threat: int = 0
var is_adrenaline_active: bool = false
var adrenaline_stacks: int = 0
var adrenaline_dodge_bonus: float = 0.15
var adrenaline_max_stacks: int = 5
var elemental_primer: GlobalData.Element = GlobalData.Element.NEUTRAL
var reaction_cooldowns: Dictionary = {}
#endregion

#region Lifecycle
func _ready():
	# Initialize stats based on the manager (which includes equipment)
	current_hp = stats_manager.get_active_max_hp()
	current_mp = stats.max_mp
	down_manager.reset_meter()

	# Enforce equipped moves slot limit (max 5)
	if equipped_moves != null and equipped_moves.size() > 5:
		while equipped_moves.size() > 5:
			equipped_moves.pop_back()

	# Connect signals from StatusManager
	status_manager.tick_damage_taken.connect(_on_tick_damage_taken)
	status_manager.tick_down_meter_increased.connect(_on_tick_down_meter_increased)
	status_manager.status_state_changed.connect(_on_status_state_changed)
	status_manager.request_ally_heal.connect(func(amt, is_enemy):
		emit_signal("request_ally_heal", amt, is_enemy))

	# Connect signal from DownManager
	down_manager.character_downed.connect(func(battler):
		is_down = true
		emit_signal("downed", battler))

	emit_signal("ui_state_changed")


func set_equipped_moves(new_moves: Array[BattleMove]) -> void:
	equipped_moves.clear()
	for move in new_moves:
		if move == null:
			continue
		if equipped_moves.size() >= 5:
			break
		equipped_moves.append(move)
	emit_signal("ui_state_changed")


func get_equipped_moves() -> Array[BattleMove]:
	return equipped_moves

func _on_tick_damage_taken(amount: int, effect_name: String):
	take_hp_damage(amount)
	print(stats.character_name, " took ", amount, " damage from ", effect_name)
	emit_signal("ui_state_changed")

func _on_tick_down_meter_increased(amount: int):
	down_manager.increase_meter(amount)
	print(stats.character_name, " had their down meter increased by ", amount)
	emit_signal("ui_state_changed")

func _on_status_state_changed() -> void:
	emit_signal("ui_state_changed")

func _set_elemental_primer(new_primer: GlobalData.Element) -> void:
	if elemental_primer == new_primer:
		return
	elemental_primer = new_primer
	emit_signal("primer_changed", elemental_primer)
	emit_signal("ui_state_changed")

func get_ui_snapshot() -> Dictionary:
	return {
		"name": stats.character_name,
		"current_hp": current_hp,
		"max_hp": stats_manager.get_active_max_hp(),
		"current_mp": current_mp,
		"max_mp": stats.max_mp,
		"is_down": down_manager.is_downed,
		"down_meter": down_manager.current_meter,
		"primer": elemental_primer,
		
		"threat": threat,
		"is_adrenaline_active": is_adrenaline_active,
		"adrenaline_stacks": adrenaline_stacks,
		"active_status": status_manager.active_status,
		"active_reaction": status_manager.active_reactions
	}
#endregion

#region Move Validation
func can_use_move(move: BattleMove) -> bool:
	if current_mp < move.mp_cost:
		print("Not enough MP to use ", move.move_name)
		return false
	if move.is_magic and status_manager.has_magic_lock():
		print("Cannot use magic moves due to a status effect!")
		return false
	if not move.is_magic and status_manager.has_physical_lock():
		print("Cannot use physical moves due to a status effect!")
		return false
	return true

func get_evasion_chance_against(attacker: Battler = null) -> float:
	var target_speed: float = float(stats_manager.get_active_speed())
	var target_luck: float = float(stats_manager.get_active_luck())
	var attacker_speed: float = target_speed
	var attacker_luck: float = target_luck

	if attacker != null:
		attacker_speed = float(attacker.stats_manager.get_active_speed())
		attacker_luck = float(attacker.stats_manager.get_active_luck())

	var base_chance: float = 0.05
	var speed_delta: float = (target_speed - attacker_speed) * 0.003
	var luck_delta: float = (target_luck - attacker_luck) * 0.002
	var adrenaline_bonus: float = get_adrenaline_dodge_bonus()

	return clampf(base_chance + speed_delta + luck_delta + adrenaline_bonus, 0.0, 0.85)

func roll_dodge(attacker: Battler = null) -> bool:
	var evasion_chance: float = get_evasion_chance_against(attacker)
	var roll: float = randf()
	var dodged: bool = roll < evasion_chance
	print(stats.character_name, " dodge roll: ", roll, " vs ", evasion_chance)
	return dodged

func enter_adrenaline_state(stack_amount: int = 1) -> void:
	is_adrenaline_active = true
	adrenaline_stacks = clampi(max(adrenaline_stacks, stack_amount), 1, adrenaline_max_stacks)
	add_threat(10 * adrenaline_stacks)
	emit_signal("adrenaline_changed", is_adrenaline_active, adrenaline_stacks)

func double_down_adrenaline() -> void:
	if not is_adrenaline_active:
		enter_adrenaline_state(1)
		return
	adrenaline_stacks = clampi(adrenaline_stacks + 1, 1, adrenaline_max_stacks)
	add_threat(10 * adrenaline_stacks)
	emit_signal("adrenaline_changed", is_adrenaline_active, adrenaline_stacks)

func consume_adrenaline_state() -> void:
	is_adrenaline_active = false
	adrenaline_stacks = 0
	emit_signal("adrenaline_changed", is_adrenaline_active, adrenaline_stacks)

func is_in_adrenaline_state() -> bool:
	return is_adrenaline_active

func get_adrenaline_stack_count() -> int:
	return adrenaline_stacks

func get_adrenaline_dodge_bonus() -> float:
	if not is_adrenaline_active or adrenaline_stacks <= 0:
		return 0.0
	if adrenaline_stacks == 1:
		return adrenaline_dodge_bonus
	if adrenaline_stacks == 2:
		return adrenaline_dodge_bonus * 0.5
	return 0.0

func get_adrenaline_defense_multiplier() -> float:
	if not is_adrenaline_active or adrenaline_stacks <= 0:
		return 1.0
	return max(0.5, 1.0 - (0.1 * float(adrenaline_stacks - 1)))

func get_adrenaline_damage_multiplier() -> float:
	if not is_adrenaline_active or adrenaline_stacks <= 0:
		return 1.0
	return 1.0 + (0.12 * float(adrenaline_stacks))

func get_adrenaline_mp_gain_multiplier() -> float:
	if not is_adrenaline_active or adrenaline_stacks <= 0:
		return 1.0
	return 1.0 + (0.10 * float(adrenaline_stacks))

func get_adrenaline_down_meter_multiplier() -> float:
	if not is_adrenaline_active or adrenaline_stacks <= 0:
		return 1.0
	if adrenaline_stacks >= 5:
		return 100.0
	return 1.0 + (0.25 * float(adrenaline_stacks))

func add_threat(amount: int) -> void:
	threat = max(0, threat + amount)
	emit_signal("threat_changed", threat)

func set_threat(value: int) -> void:
	threat = max(0, value)
	emit_signal("threat_changed", threat)

func clear_threat() -> void:
	set_threat(0)

func get_threat_value() -> int:
	return threat
#endregion

#region Defense And Damage
func take_damage(power: int, is_magic: bool, element: GlobalData.Element = GlobalData.Element.NEUTRAL, phys_type: GlobalData.PhysicalType = GlobalData.PhysicalType.NONE, attacker_is_crit: bool = false, _crit_mult: float = 1.0, attacker: Battler = null) -> bool:
	
	# 1. Elements and Reactions
	var reaction_multiplier := 1.0
	if is_magic:
		reaction_multiplier = apply_element(element)

	var defense = stats_manager.get_active_def(is_magic)
	var affinity_multiplier: float = affinity_manager.get_damage_multiplier(is_magic, element, phys_type)
	var is_weakness: bool = affinity_manager.is_weakness_hit(is_magic, element, phys_type)

	var is_resist: bool = affinity_manager.get_current_affinity(is_magic, element, phys_type) == BattlerStats.Affinity.RESIST
	if affinity_manager.is_blocked(is_magic, element, phys_type):
		print(stats.character_name, " NULLIFIED the attack! (0 Damage)")
		emit_signal("damage_resolved", 0, current_hp, stats_manager.get_active_max_hp(), down_manager.current_meter, false, false, false, true, null)
		return false

	# 3. Strict Crit Logic (Physical Only)
	var final_crit = false
	if not is_magic:
		if attacker_is_crit:
			final_crit = true
			print("CRITICAL HIT! (Natural Roll)")
		
		# This safely checks AND consumes the mark in one go!
		if status_manager.guaranteed_crit():
			final_crit = true
			print("CRITICAL HIT! (Target was Exposed)")

	# 4. Final Math
	# NOTE: Crit bonus is now applied to base power BEFORE weakness/reaction scaling
	# This ensures crits are not reduced by weakness multipliers
	var final_multiplier = affinity_multiplier * reaction_multiplier
	
	# Randomize base power around the move's midpoint with a strict +/- 5 range.
	var randomized_power: int = randi_range(max(1, power - 5), max(1, power + 5))

	# Damage Calculation (Multipliers apply BEFORE defense!)
	var final_damage = roundi((randomized_power * final_multiplier) - defense)
	final_damage = max(1, final_damage)

	take_hp_damage(final_damage)
	emit_signal("damage_taken", final_damage, final_crit, is_weakness)
	print(stats.character_name, " took ", final_damage, " damage!")
	# Emit a post-calculation UI-friendly signal so UI logic can react without being
	# tightly coupled to the combat flow. Provide affinity info for resist/block.
	emit_signal("damage_resolved", final_damage, current_hp, stats_manager.get_active_max_hp(), down_manager.current_meter, is_weakness, final_crit, is_resist, false, attacker)

	# 5. Down Meter Math
	if not down_manager.is_downed:
		var downpwr: int = 0
		
		if status_manager.has_instant_down_exposure():
			downpwr = 100
			print(stats.character_name, " was EXPOSED! INSTANT DOWN!")
		elif is_weakness or final_crit:
			# Weakness and Crit hits fill 10-20 down meter
			downpwr = randi_range(10, 20)
		else:
			# Normal attacks fill less than 5 (1-4)
			downpwr = randi_range(1, 4)

		# Apply attacker Adrenaline multiplier and status multiplier
		if not status_manager.has_instant_down_exposure():
			var down_mult = status_manager.get_down_meter_fill_multiplier()
			var attacker_down_mult: float = attacker.get_adrenaline_down_meter_multiplier() if attacker != null else 1.0
			downpwr = roundi(float(downpwr) * down_mult * attacker_down_mult)
			if attacker != null and attacker.is_in_adrenaline_state() and attacker.get_adrenaline_stack_count() >= 5:
				downpwr = 100

		print("Down power : ", downpwr)
		down_manager.increase_meter(downpwr)
        
		# ---> NEW: The Cleanup (Shatter Logic) <---
		# We use your existing `is_magic` bool to tell the StatusManager what kind of hit this was
		var hit_type = "magic" if is_magic else "physical"
		status_manager.check_removal_triggers(hit_type)

	if attacker != null and is_adrenaline_active:
		consume_adrenaline_state()

	return is_weakness

#endregion

#region Elemental Reactions
func apply_element(incoming_element: GlobalData.Element) -> float:
	if incoming_element == GlobalData.Element.NEUTRAL:
		return 1.0

	if elemental_primer == GlobalData.Element.NEUTRAL:
		_set_elemental_primer(incoming_element)
		var element_name = GlobalData.Element.keys()[incoming_element]
		print(stats.character_name, " is primed: ", element_name)
		return 1.0
	else:
		return trigger_reaction(elemental_primer, incoming_element)

func trigger_reaction(primer: GlobalData.Element, trigger: GlobalData.Element) -> float:
	var applied_status = ItemDatabase.find_chain_reaction(primer, trigger)

	if applied_status != null:
		# Cooldown Check
		if reaction_cooldowns.has(applied_status.id) and reaction_cooldowns[applied_status.id] > 0:
			print(stats.character_name, " RESISTED the reaction! (On Cooldown)")
			_set_elemental_primer(trigger)
			return 1.0

		print("CHAIN REACTION TRIGGERED: ", applied_status.effect_name, "!")
		print("[DEBUG] applied_status.is_chain_reaction=", applied_status.is_chain_reaction, " guarantees_next_crit=", applied_status.guarantees_next_crit)
		var burst_multiplier: float = applied_status.reaction_burst_mult

		# Scaling Math
		if applied_status.damage_scales_with_debuffs:
			var debuff_count = status_manager.count_debuffs()
			burst_multiplier += (debuff_count * 0.5)
			print("Reaction scaled by ", debuff_count, " debuffs. Multiplier is now ", burst_multiplier, "x!")

		if applied_status.clears_all_statuses:
			status_manager.clear_status_effects()
		# temporary test for stealing buffs with a reaction - if the applied status is "Splinter", we also apply a "Stolen Defense" buff to the target
		if applied_status.effect_name == "Splinter" :
			var steal_buff = StatusEffect.new()
			steal_buff.effect_name = "Stolen Defense"
			steal_buff.stat_mult_defense = 0.5 # +50% defense
			steal_buff.duration_turns = 2

		# Remove old reactions so they don't stack infinitely
		status_manager.override_old_chain_reactions()
		
		# Apply the reaction
		status_manager.apply_status_effect(applied_status)
		print("[DEBUG] after apply_status_effect: active_reactions=", status_manager.active_reactions != null, " active_status_count=", status_manager.active_status.size())
		
		# Setup friendly fire behaviors
		_setup_friendly_fire(applied_status)
		
		_set_elemental_primer(GlobalData.Element.NEUTRAL)
		reaction_cooldowns[applied_status.id] = 3
		emit_signal("ui_state_changed")

		return burst_multiplier
	else:
		_set_elemental_primer(trigger)
		var element_name = GlobalData.Element.keys()[trigger]
		print(stats.character_name, " is primed: ", element_name)
		return 1.0

#region Friendly Fire Setup
func _setup_friendly_fire(reaction: StatusEffect):
	# Type 1: Chain reaction affects whole party (AoE to allies)
	if reaction.applies_to_all_allies:
		status_manager.set_party_wide_damage(true)
		print("PARTY-WIDE AoE EFFECT!")
	
	# Type 2: Brainwash - target attacks their own party
	if reaction.chance_friendly_fire > 0.0:
		if randf() < reaction.chance_friendly_fire:
			status_manager.set_brainwash(true)
			print("BRAINWASH EFFECT TRIGGERED!")
	
	# Type 3: Affects both parties
	if reaction.affects_both_parties:
		status_manager.set_affects_both_parties(true)
		print("EFFECT SPREADS TO BOTH PARTIES!")
#endregion

#region Resource Management (Molecular Heals)
func heal_hp(amount: int):
	if status_manager.has_heal_block():
		print(stats.character_name, " is affected by a heal block and cannot be healed!")
		return
		
	set_current_hp(current_hp + amount)
	emit_signal("ui_state_changed")
	print(stats.character_name, " healed for ", amount, " HP!")

func take_hp_damage(amount: int) -> void:
	if amount <= 0:
		return
	set_current_hp(current_hp - amount)

func set_current_hp(value: int) -> void:
	current_hp = clampi(value, 0, stats_manager.get_active_max_hp())
	emit_signal("health_changed", current_hp)

func heal_mp(amount: int):
	if amount <= 0:
		return
	set_current_mp(current_mp + amount)
	print(stats.character_name, " healed for ", amount, " MP!")

func spend_mp(amount: int) -> int:
	if amount <= 0:
		return 0
	var spent: int = min(current_mp, amount)
	set_current_mp(current_mp - spent)
	return spent

func set_current_mp(value: int) -> void:
	current_mp = clampi(value, 0, stats.max_mp)
	emit_signal("mana_changed", current_mp)
	emit_signal("ui_state_changed")
	
func consume_item(item: Consumable):
	print(stats.character_name, " Used ", item.item_name)

	# Route items through the molecular functions!
	# Single-target (self) behaviour
	if item.target_scope == Consumable.TargetScope.SELF or item.target_scope == Consumable.TargetScope.SINGLE_ALLY:
		if item.heals_hp > 0:
			heal_hp(item.heals_hp)
		if item.heals_mp > 0:
			heal_mp(item.heals_mp)
		if item.cures_status:
			status_manager.clear_status_effects()
			_set_elemental_primer(GlobalData.Element.NEUTRAL)
			print(stats.character_name, " was cured of all ailments!")
		if item.applied_buff != null:
			status_manager.apply_status_effect(item.applied_buff)
		if item.applied_debuff != null:
			status_manager.apply_status_effect(item.applied_debuff)

	# Lowest ally heal (uses existing BattleManager handler to heal lowest ally)
	elif item.target_scope == Consumable.TargetScope.LOWEST_ALLY:
		if item.heals_hp > 0:
			emit_signal("request_ally_heal", item.heals_hp, false)
		# Broadcast the item so a BattleManager can handle multi-target buffs/debuffs
		if item.applied_buff != null or item.applied_debuff != null or item.cures_status:
			emit_signal("request_item_broadcast", item, int(item.target_scope))

	# Party / enemy / global scope: emit a broadcast so a higher-level manager applies the item to the proper targets.
	else:
		# For wide effects we only broadcast the item; BattleManager should listen to `request_item_broadcast` and apply per-party logic.
		emit_signal("request_item_broadcast", item, int(item.target_scope))

func apply_status_effect(effect: StatusEffect):
	"""Wrapper for clean API access to status manager"""
	status_manager.apply_status_effect(effect)
#endregion

#region Turn
func process_turn_start():
	# Tick down reaction cool downs
	for reaction in reaction_cooldowns.keys():
		if reaction_cooldowns[reaction] > 0:
			reaction_cooldowns[reaction] -= 1

	status_manager.process_turn_start()
	emit_signal("ui_state_changed")

#endregion
