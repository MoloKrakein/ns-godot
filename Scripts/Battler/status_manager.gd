extends Node
class_name StatusManager

signal status_applied(effect)
signal status_removed(effect)
signal chain_reaction_triggered(reaction)
signal status_state_changed
signal tick_damage_taken(amount: int, effect_name: String)
signal tick_down_meter_increased(amount: int)
signal request_ally_heal(amount: int, is_enemy: bool)

@onready var battler = get_parent() 
var active_status: Array[StatusEffect] = []
var active_reactions: StatusEffect = null 
var reaction_duration: int = 0

#region Friendly Fire States
var brainwashed: bool = false 
var shares_damage_with_party: bool = false 
var affects_both_parties: bool = false 
#endregion

#region Status Effect Management
func apply_status_effect(effect: StatusEffect):
	var effect_instance = effect.duplicate(true)
	
	if effect_instance.duration_turns <= 0:
		effect_instance.duration_turns = 2
		
	# Debug: show incoming effect flags and instance copy
	print("[DEBUG] apply_status_effect: effect_name=", effect.effect_name, " effect.is_chain_reaction=", effect.is_chain_reaction, " effect.guarantees_next_crit=", effect.guarantees_next_crit)
	print("[DEBUG] apply_status_effect: instance.guarantees_next_crit=", effect_instance.guarantees_next_crit)
	
	if effect.is_chain_reaction:
		_trigger_chain_reaction(effect_instance)
		print("Applied chain reaction: ", effect_instance.effect_name, " to ", battler.stats.character_name)
	else:
		active_status.append(effect_instance)
		print("Applied status effect: ", effect_instance.effect_name, " to ", battler.stats.character_name)
		emit_signal("status_applied", effect_instance)
		_emit_status_state_changed()

func clear_status_effects():
	for status in active_status:
		emit_signal("status_removed", status)
	active_status.clear()
	remove_active_reaction() # Use the cleanup function!
	_emit_status_state_changed()
	print("Cleared all status effects from ", battler.stats.character_name)

func override_old_chain_reactions():
	var removed_any: bool = false
	for i in range(active_status.size() -1, -1, -1):
		if active_status[i].is_chain_reaction:
			emit_signal("status_removed", active_status[i])
			active_status.remove_at(i)
			removed_any = true
	if removed_any:
		_emit_status_state_changed()

func _trigger_chain_reaction(reaction: StatusEffect):
	if active_reactions != null:
		emit_signal("status_removed", active_reactions)
	active_reactions = reaction
	emit_signal("status_applied", reaction)
	emit_signal("chain_reaction_triggered", reaction)
	_emit_status_state_changed()

	if reaction.is_conductive:
		_handle_conductor_reaction(reaction)

# --- BUG 2 FIX: CLEAN UP THE FLAGS SO THEY DON'T BLEED ---
func remove_active_reaction():
	if active_reactions != null:
		emit_signal("status_removed", active_reactions)
	active_reactions = null
	brainwashed = false
	shares_damage_with_party = false
	affects_both_parties = false
	_emit_status_state_changed()
	print("Removed active chain reaction and cleared flags from ", battler.stats.character_name)

func process_turn_start():
	# Tick normal status effects
	for i in range(active_status.size() -1, -1, -1):
		var status = active_status[i]
		_process_tick(status)

		status.duration_turns -= 1
		if status.duration_turns < 0:
			print(status.effect_name, " has worn off from ", battler.stats.character_name, "!")
			emit_signal("status_removed", status)
			active_status.remove_at(i)
			_emit_status_state_changed()

	# Tick active chain reaction
	if active_reactions != null:
		_process_tick(active_reactions) 
		active_reactions.duration_turns -= 1 
		if active_reactions.duration_turns < 0:
			print(active_reactions.effect_name, " has worn off from ", battler.stats.character_name, "!")
			remove_active_reaction() # Use the cleanup function!

# --- BUG 3 FIX: INDENTATION PULLED OUT OF THE FOR LOOP ---
func check_removal_triggers(attack_type: String):
	for i in range(active_status.size() -1, -1, -1):
		var status = active_status[i]
		if (attack_type == "physical" and status.removes_on_physical_hit) or (attack_type == "magic" and status.removes_on_magic_hit):
			print(status.effect_name, " was removed from ", battler.stats.character_name, " due to ", attack_type, " hit!")
			emit_signal("status_removed", status)
			active_status.remove_at(i)
			_emit_status_state_changed()

	# THIS MUST BE OUTSIDE THE FOR LOOP!
	if active_reactions != null:
		if (attack_type == "physical" and active_reactions.removes_on_physical_hit) or (attack_type == "magic" and active_reactions.removes_on_magic_hit):
			print("SHATTER! ", active_reactions.effect_name, " was removed due to ", attack_type, " hit!")
			remove_active_reaction() # Use the cleanup function!

#endregion

#region Helper Functions
func has_heal_block() -> bool:
	for status in active_status:
		if status.disables_healing: return true 
	if active_reactions != null and active_reactions.disables_healing: return true
	return false

func is_stunned() -> bool:
	for status in active_status:
		if status.is_stunned: return true 
	if active_reactions != null and active_reactions.is_stunned: return true
	return false

func has_zero_defense() -> bool: 
	for status in active_status:
		if status.sets_defense_to_zero: return true 
	if active_reactions != null and active_reactions.sets_defense_to_zero: return true
	return false

func has_flipped_weakness() -> bool: 
	for status in active_status:
		if status.flips_weaknesses: return true 
	if active_reactions != null and active_reactions.flips_weaknesses: return true
	return false

func has_magic_lock() -> bool:
	for status in active_status:
		if status.locks_magic: return true
	if active_reactions != null and active_reactions.locks_magic: return true
	return false

func has_physical_lock() -> bool:
	for status in active_status:
		if status.locks_physical: return true
	if active_reactions != null and active_reactions.locks_physical: return true
	return false

func has_instant_down_exposure() -> bool:
	for status in active_status:
		if status.get("causes_instant_down"): return true
	if active_reactions != null and active_reactions.get("causes_instant_down"): return true
	return false

func guaranteed_crit() -> bool:
	for i in range(active_status.size() - 1, -1, -1):
		if active_status[i].guarantees_next_crit:
			var name = active_status[i].effect_name
			emit_signal("status_removed", active_status[i])
			active_status.remove_at(i) 
			_emit_status_state_changed()
			print("guaranteed_crit: consumed from active_status -> ", name)
			return true
			
	if active_reactions != null and active_reactions.guarantees_next_crit:
		print("guaranteed_crit: consumed from active_reactions -> ", active_reactions.effect_name)
		remove_active_reaction()
		return true
	return false

func has_guaranteed_crit() -> bool:
	for status in active_status:
		if status.guarantees_next_crit:
			return true
	if active_reactions != null and active_reactions.guarantees_next_crit:
		return true
	return false

func count_debuffs() -> int:
	var debuff_count = 0
	for status in active_status:
		if status.effect_type == StatusEffect.Type.DEBUFF: debuff_count += 1
	if active_reactions != null and active_reactions.effect_type == StatusEffect.Type.DEBUFF: debuff_count += 1
	return debuff_count

#region Conductive & Proxy AoE
func has_conductive_reaction() -> bool:
	if active_reactions != null and active_reactions.is_conductive: return true
	for status in active_status:
		if status.is_conductive: return true
	return false

func get_conductive_reaction() -> StatusEffect:
	if active_reactions != null and active_reactions.is_conductive: return active_reactions
	for status in active_status:
		if status.is_conductive: return status
	return null

func apply_conductive_damage(base_damage: int, jumps: int = 0) -> int:
	var conductive = get_conductive_reaction()
	if conductive == null: return base_damage
	var final_damage = base_damage
	for i in range(jumps):
		final_damage = int(final_damage * (1.0 - conductive.decay_per_jump))
		final_damage = max(1, final_damage)
	return final_damage
#endregion

#region Friendly Fire Helpers
func is_brainwashed() -> bool: return brainwashed
func set_brainwash(state: bool):
	brainwashed = state
	_emit_status_state_changed()
	if state: print(battler.stats.character_name, " has been BRAINWASHED!")
	else: print(battler.stats.character_name, " is no longer brainwashed!")

func should_share_damage_party_wide() -> bool: return shares_damage_with_party
func set_party_wide_damage(state: bool):
	shares_damage_with_party = state
	_emit_status_state_changed()
func affects_both_teams() -> bool: return affects_both_parties
func set_affects_both_parties(state: bool):
	affects_both_parties = state
	_emit_status_state_changed()
#endregion

func _process_tick(status):
	if status.dot_dmg > 0: emit_signal("tick_damage_taken", status.dot_dmg, status.effect_name)
	if status.down_meter_fill_per_turn > 0 and not battler.is_down: emit_signal("tick_down_meter_increased", status.down_meter_fill_per_turn)
	if status.heals_lowest_ally_per_turn > 0 :
		var is_enemy = (battler.get_parent().name == "EnemyParty")
		emit_signal("request_ally_heal", status.heals_lowest_ally_per_turn, is_enemy)

func get_stats_multiplier(stat_type: String) -> float:
	var total_mult = 1.0
	var apply_mult = func(val: float): return 1.0 + val 
	for status in active_status: total_mult *= apply_mult.call(_get_val_from_status(status, stat_type))
	if active_reactions != null: total_mult *= apply_mult.call(_get_val_from_status(active_reactions, stat_type))
	return max(0.1, total_mult) 

func get_down_meter_fill_multiplier() -> float:
	var mult = 1.0
	var apply_mult = func(val: float): return 1.0 + val 
	for status in active_status: mult *= apply_mult.call(_get_val_from_status(status, "down_meter_fill"))
	if active_reactions != null: mult *= apply_mult.call(_get_val_from_status(active_reactions, "down_meter_fill"))
	return max(0.1, mult) 

func _get_val_from_status(status: StatusEffect, stat_type: String) -> float:
	match stat_type:
		"strength": return status.stat_mult_strength
		"magic": return status.stat_mult_magic
		"defense": return status.stat_mult_defense
		"speed": return status.stat_mult_speed
		"accuracy": return status.stat_mult_accuracy
		"crit_chance": return status.stat_mult_crit_chance
		"crit_dmg": return status.stat_mult_crit_dmg
		"down_meter_fill": return status.stat_mult_down_meter_fill
	return 0.0
	

func _handle_conductor_reaction(reaction: StatusEffect): pass

func _emit_status_state_changed() -> void:
	emit_signal("status_state_changed")

func get_active_status() -> Array[StatusEffect]:
	var out = active_status.duplicate()
	if active_reactions != null: out.append(active_reactions)
	return out
#endregion
