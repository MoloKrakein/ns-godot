extends Node

signal adrenaline_ui_requested(battler: Battler, payload: Dictionary)
signal party_member_swapped(outgoing: Battler, incoming: Battler, is_enemy_party: bool)
signal turn_started(active_battler: Battler)

@export var max_active_players: int = 1
@export var max_active_enemies: int = 1

var player_party: Array[Battler] = []
var enemy_party: Array[Battler] = []
var player_active_party: Array[Battler] = []
var enemy_active_party: Array[Battler] = []
var player_reserve_party: Array[Battler] = []
var enemy_reserve_party: Array[Battler] = []
var turn_queue: Array[Battler] = []
var adrenaline_battlers: Array[Battler] = []
var overdrive_parties: Dictionary = {false: false, true: false}
var current_turn_battler: Battler = null

#region AoE & Conductive Tracking
var last_reaction_triggered: StatusEffect = null # Track the last reaction to apply AoE
var conductive_targets: Array[Battler] = [] # Targets to spread conductive damage to
#endregion

func _ready() -> void:
	print("Battle Scene Ready!")

	# 1. Grab the children from the Node2D folders and put them in our Arrays
	# $NodeName is Godot's shorthand for get_node("NodeName")
	for child in $PlayerParty.get_children():
		if child is Battler:
			player_party.append(child)
			child.request_ally_heal.connect(_on_battler_request_ally_heal)
			child.adrenaline_changed.connect(_on_battler_adrenaline_changed.bind(child))

	for child in $EnemyParty.get_children():
		if child is Battler:
			enemy_party.append(child)
			child.request_ally_heal.connect(_on_battler_request_ally_heal)
			child.adrenaline_changed.connect(_on_battler_adrenaline_changed.bind(child))

	# Connect down state observers
	for battler in player_party:
		battler.down_manager.character_downed.connect(_on_battler_downed)
	for battler in enemy_party:
		battler.down_manager.character_downed.connect(_on_battler_downed)

	_initialize_battle_formations()

	# 2. Run the Test Simulation!

#region Turn Queue Logic
func build_turn_queue() -> void:
	turn_queue.clear()
	turn_queue.append_array(player_active_party)
	turn_queue.append_array(enemy_active_party)

	# Sort
	turn_queue.sort_custom(_sort_by_speed)

	print("Turn Queue Built! Turn order:")
	for battler in turn_queue:
		print("- ", battler.stats.character_name, " (Speed: ", battler.stats.speed, ")")

func _sort_by_speed(a: Battler, b: Battler) -> bool:
	return a.stats.speed > b.stats.speed

func get_highest_threat_target(targets: Array[Battler]) -> Battler:
	var chosen_target: Battler = null
	for battler in targets:
		if battler == null or battler.current_hp <= 0:
			continue
		if chosen_target == null or battler.get_threat_value() > chosen_target.get_threat_value():
			chosen_target = battler
	return chosen_target

func get_adrenaline_battlers() -> Array[Battler]:
	return adrenaline_battlers.duplicate()

func get_adrenaline_ui_payload(battler: Battler) -> Dictionary:
	return {
		"name": battler.stats.character_name,
		"stacks": battler.get_adrenaline_stack_count(),
		"is_active": battler.is_in_adrenaline_state(),
		"threat": battler.get_threat_value(),
		"evasion_bonus": battler.get_adrenaline_dodge_bonus(),
		"damage_multiplier": battler.get_adrenaline_damage_multiplier(),
		"mp_multiplier": battler.get_adrenaline_mp_gain_multiplier(),
		"down_meter_multiplier": battler.get_adrenaline_down_meter_multiplier()
	}

func request_adrenaline_ui(battler: Battler) -> void:
	if battler == null:
		return
	adrenaline_ui_requested.emit(battler, get_adrenaline_ui_payload(battler))

func get_active_party(is_enemy_party: bool) -> Array[Battler]:
	return enemy_active_party if is_enemy_party else player_active_party

func get_reserve_party(is_enemy_party: bool) -> Array[Battler]:
	return enemy_reserve_party if is_enemy_party else player_reserve_party

func is_battler_active(battler: Battler) -> bool:
	return battler in player_active_party or battler in enemy_active_party

func swap_party_member(outgoing: Battler, incoming: Battler) -> bool:
	if outgoing == null or incoming == null:
		return false

	var outgoing_is_enemy: bool = outgoing in enemy_party
	var incoming_is_enemy: bool = incoming in enemy_party
	var outgoing_is_player: bool = outgoing in player_party
	var incoming_is_player: bool = incoming in player_party

	if not ((outgoing_is_enemy and incoming_is_enemy) or (outgoing_is_player and incoming_is_player)):
		printerr("Swap failed: both battlers must be from the same party")
		return false

	var is_enemy_party: bool = outgoing_is_enemy and incoming_is_enemy
	var active_party: Array[Battler] = get_active_party(is_enemy_party)
	var reserve_party: Array[Battler] = get_reserve_party(is_enemy_party)

	if outgoing not in active_party:
		printerr("Swap failed: outgoing battler is not currently active")
		return false
	if incoming not in reserve_party:
		printerr("Swap failed: incoming battler is not in reserves")
		return false
	if incoming.current_hp <= 0:
		printerr("Swap failed: incoming battler has no HP")
		return false

	active_party.erase(outgoing)
	reserve_party.erase(incoming)
	active_party.append(incoming)

	if outgoing.current_hp > 0:
		reserve_party.append(outgoing)

	if outgoing in turn_queue:
		turn_queue.erase(outgoing)
	if incoming not in turn_queue and incoming.current_hp > 0:
		turn_queue.append(incoming)
	turn_queue.sort_custom(_sort_by_speed)

	party_member_swapped.emit(outgoing, incoming, is_enemy_party)
	print("SWAP: ", outgoing.stats.character_name, " -> ", incoming.stats.character_name)
	return true

func _initialize_battle_formations() -> void:
	player_active_party.clear()
	player_reserve_party.clear()
	enemy_active_party.clear()
	enemy_reserve_party.clear()

	_split_party_into_active_and_reserve(player_party, player_active_party, player_reserve_party, max_active_players)
	_split_party_into_active_and_reserve(enemy_party, enemy_active_party, enemy_reserve_party, max_active_enemies)

	print("Player active: ", player_active_party.size(), " reserve: ", player_reserve_party.size())
	print("Enemy active: ", enemy_active_party.size(), " reserve: ", enemy_reserve_party.size())

func _split_party_into_active_and_reserve(full_party: Array[Battler], active_party: Array[Battler], reserve_party: Array[Battler], max_active: int) -> void:
	var clamped_max_active: int = maxi(1, max_active)

	for battler in full_party:
		if active_party.size() < clamped_max_active:
			active_party.append(battler)
		else:
			reserve_party.append(battler)

func start_next_turn() -> Battler:
	if turn_queue.is_empty():
		print("Queue Empty !")
		current_turn_battler = null
		return null
	var curr_battler: Battler = turn_queue.pop_front()
	if not is_battler_active(curr_battler) or curr_battler.current_hp <= 0:
		return start_next_turn()
	current_turn_battler = curr_battler
	print("\n--- ", curr_battler.stats.character_name, "'s Turn! ---")
	turn_started.emit(curr_battler)
	curr_battler.process_turn_start()

	# TODO: Check for skip_turn status effects here later!

	# For now, put them back at the end of the line so the loop can continue later
	turn_queue.append(curr_battler)
	return curr_battler

func get_current_turn_battler() -> Battler:
	return current_turn_battler

#endregion

#region Down State Helpers
func is_battler_down(battler: Battler) -> bool:
	return battler.down_manager.is_downed

func is_party_down(party: Array[Battler]) -> bool:
	for battler in party:
		if battler.current_hp > 0 and not battler.down_manager.is_downed:
			return false
	return true

func check_party_downs() -> bool:
	var player_all_down = is_party_down(player_party)
	var enemy_all_down = is_party_down(enemy_party)

	if player_all_down:
		print("PLAYER PARTY ALL DOWN! Enemy Overdrive triggered!")
		set_party_overdrive(true, true)

	if enemy_all_down:
		print("ENEMY PARTY ALL DOWN! Battle won!")
		set_party_overdrive(false, true)

	return player_all_down or enemy_all_down

func set_party_overdrive(is_enemy_party: bool, active: bool) -> void:
	if overdrive_parties.get(is_enemy_party, false) == active:
		return

	overdrive_parties[is_enemy_party] = active
	for battler in _get_full_party(is_enemy_party):
		if battler != null:
			battler.set_ascended_state(active)

	var party_name: String = "Enemy" if is_enemy_party else "Player"
	if active:
		print(party_name, " party entered OVERDRIVE placeholder state!")
	else:
		print(party_name, " party exited OVERDRIVE placeholder state!")

func _get_full_party(is_enemy_party: bool) -> Array[Battler]:
	return enemy_party if is_enemy_party else player_party

func _on_battler_downed(battler: Battler) -> void:
	print(battler.stats.character_name, " has entered DOWN STATE!")
	check_party_downs()

func _on_battler_adrenaline_changed(is_active: bool, stacks: int, battler: Battler) -> void:
	if is_active:
		if battler not in adrenaline_battlers:
			adrenaline_battlers.append(battler)
		print(battler.stats.character_name, " entered Adrenaline at stack ", stacks)
	else:
		if battler in adrenaline_battlers:
			adrenaline_battlers.erase(battler)
		print(battler.stats.character_name, " left Adrenaline")

#endregion

#region Move
func execute_move(attacker: Battler, move: BattleMove, primary_target: Battler = null) -> void:
	print("\n>>> ", attacker.stats.character_name, " uses ", move.move_name, "! <<<")

	# Check if attacker is brainwashed and redirect targets
	if attacker.status_manager.is_brainwashed():
		print("  (", attacker.stats.character_name, " is BRAINWASHED - attacking own allies!)")

	var targets: Array[Battler] = _get_move_targets(attacker, move, primary_target)

	for target in targets:
		if not _should_process_move_target(attacker, move, target):
			continue

		_apply_move_effects(attacker, move, target)

	# --- D) POST-MOVE: Handle AoE Reactions ---
	_process_post_move_aoe(attacker, targets)

func _get_move_targets(attacker: Battler, move: BattleMove, primary_target: Battler = null) -> Array[Battler]:
	var targets: Array[Battler] = []
	var attacker_is_enemy: bool = attacker in enemy_party
	var ally_active_party: Array[Battler] = get_active_party(attacker_is_enemy)
	var enemy_active_party_for_attacker: Array[Battler] = get_active_party(not attacker_is_enemy)

	match move.target_type:
		BattleMove.Target.SINGLE_ENEMY, BattleMove.Target.SINGLE_ALLY:
			if primary_target != null:
				targets.append(primary_target)
		BattleMove.Target.ALL_ENEMIES:
			if attacker.status_manager.is_brainwashed():
				targets.append_array(ally_active_party)
			else:
				targets.append_array(enemy_active_party_for_attacker)
		BattleMove.Target.ALL_ALLIES:
			targets.append_array(ally_active_party)
		BattleMove.Target.SELF:
			targets.append(attacker)

	return targets

func _should_process_move_target(attacker: Battler, move: BattleMove, target: Battler) -> bool:
	if target.current_hp <= 0:
		return false

	print("-> Targeting ", target.stats.character_name)

	# Placeholder dodge / evasion check.
	if move.power > 0 and target.roll_dodge(attacker):
		print("-> ", target.stats.character_name, " dodged the attack!")
		return false

	return true

func _apply_move_effects(attacker: Battler, move: BattleMove, target: Battler) -> void:
	# --- A) DEAL DAMAGE ---
	if move.power > 0:
		_apply_move_damage(attacker, move, target)

	# --- B) HEAL HP / MP ---
	if move.heals_hp > 0:
		_apply_move_healing(target, move.heals_hp)

	if move.heals_mp > 0:
		_apply_move_mana_restore(attacker, target, move.heals_mp)

	# --- C) APPLY STATUS EFFECTS ---
	if move.applied_status != null:
		_apply_move_status(attacker, move, target)

func _apply_move_damage(attacker: Battler, move: BattleMove, target: Battler) -> void:
	var total_power: int = move.power
	var scaling_stat: int = attacker.stats_manager.get_active_magic() if move.is_magic else attacker.stats_manager.get_active_strength()
	var stat_bonus: int = roundi(float(scaling_stat) * 0.2)
	total_power += stat_bonus
	if attacker.is_in_adrenaline_state():
		total_power = roundi(float(total_power) * attacker.get_adrenaline_damage_multiplier())
	total_power = max(1, total_power)

	var is_crit := false
	if not move.is_magic:
		var final_crit_chance: float = attacker.stats_manager.get_active_crit_chance()
		print("[DEBUG] Checking guaranteed crit for ", target.stats.character_name)
		for s in target.status_manager.active_status:
			print("[DEBUG]  status: ", s.effect_name, " guarantees_next_crit=", s.guarantees_next_crit)
		if target.status_manager.active_reactions != null:
			print("[DEBUG]  active_reaction: ", target.status_manager.active_reactions.effect_name, " guarantees_next_crit=", target.status_manager.active_reactions.guarantees_next_crit)
		if target.status_manager.has_guaranteed_crit():
			print("Guaranteed crit triggered on ", target.stats.character_name, "!")
			final_crit_chance = 1.0
			is_crit = true
		var crit_roll := randf()
		if crit_roll <= final_crit_chance:
			is_crit = true
			print("CRITICAL HIT! (Roll: ", crit_roll, " <= ", final_crit_chance, ")")

	# Apply crit bonus to base power BEFORE weakness/reaction scaling
	if is_crit:
		var crit_dmg_mult: float = attacker.stats_manager.get_active_crit_dmg()
		total_power = roundi(float(total_power) * crit_dmg_mult)
		total_power = max(1, total_power)
	var was_weakness_hit: bool = target.take_damage(total_power, move.is_magic, move.element, move.physical_type, is_crit, 1.0, attacker)
	if was_weakness_hit:
		attacker.enter_adrenaline_state()

func _apply_move_healing(target: Battler, heal_amount: int) -> void:
	target.current_hp += heal_amount
	target.current_hp = min(target.current_hp, target.stats_manager.get_active_max_hp())
	target.emit_signal("health_changed", target.current_hp)
	print(target.stats.character_name, " healed for ", heal_amount, " HP!")

func _apply_move_mana_restore(attacker: Battler, target: Battler, mana_amount: int) -> void:
	var mp_restore: int = mana_amount
	if attacker.is_in_adrenaline_state():
		mp_restore = roundi(float(mp_restore) * attacker.get_adrenaline_mp_gain_multiplier())
	target.current_mp += mp_restore
	target.current_mp = min(target.current_mp, target.stats_manager.get_active_max_mp())
	target.emit_signal("mana_changed", target.current_mp)
	print(target.stats.character_name, " restored ", mp_restore, " MP!")

func _apply_move_status(_attacker: Battler, move: BattleMove, target: Battler) -> void:
	if randf() <= move.status_chance:
		target.apply_status_effect(move.applied_status)
	else:
		print("The status effect missed ", target.stats.character_name, "!")

#endregion

#region AoE & Conductive Reaction Handling
func _process_post_move_aoe(attacker: Battler, initial_targets: Array[Battler]) -> void:
	# Process chain reactions triggered on each of the primary targets.
	# Previously this only checked the attacker's active_reactions which
	# prevented reactions applied to targets from spreading. Iterate through
	# initial_targets and handle any chain reactions found on those targets.
	for origin in initial_targets:
		if origin == null:
			continue
		var active_reaction: StatusEffect = origin.status_manager.active_reactions
		if active_reaction == null or not active_reaction.is_chain_reaction:
			continue

		var origin_is_enemy: bool = origin in enemy_party
		var ally_active_party: Array[Battler] = get_active_party(origin_is_enemy)
		var enemy_active_party_for_origin: Array[Battler] = get_active_party(not origin_is_enemy)

		if active_reaction.applies_to_all_enemies:
			for enemy in enemy_active_party_for_origin:
				if enemy.current_hp > 0 and enemy not in initial_targets:
					_apply_aoe_reaction(origin, enemy, active_reaction)

		if active_reaction.applies_to_all_allies:
			for ally in ally_active_party:
				if ally.current_hp > 0 and ally not in initial_targets:
					_apply_aoe_reaction(origin, ally, active_reaction)

		if active_reaction.is_conductive:
			_apply_conductive_spread(origin, initial_targets, active_reaction)

		if active_reaction.affects_both_parties:
			var all_battlers = player_active_party + enemy_active_party
			for battler in all_battlers:
				if battler.current_hp > 0 and battler not in initial_targets:
					_apply_aoe_reaction(origin, battler, active_reaction)

func _apply_aoe_reaction(_attacker: Battler, target: Battler, reaction: StatusEffect) -> void:
	print("AoE SPREAD: ", reaction.effect_name, " hits ", target.stats.character_name, "!")
	target.status_manager.apply_status_effect(reaction)
	if reaction.dot_dmg > 0:
		var reduced_damage: int = int(reaction.dot_dmg * 0.7)
		target.take_damage(reduced_damage, false)

func _apply_conductive_spread(attacker: Battler, initial_targets: Array[Battler], reaction: StatusEffect) -> void:
	var attacker_is_player = attacker in player_party
	var potential_targets = enemy_active_party if attacker_is_player else player_active_party
	if initial_targets.is_empty():
		return
	var source_primer: GlobalData.Element = initial_targets[0].elemental_primer
	var jump_index: int = 1

	print("CONDUCTIVE SPREAD triggered for ", reaction.effect_name)

	for target in potential_targets:
		if target.current_hp <= 0 or target in initial_targets:
			continue
		if target.elemental_primer != source_primer:
			continue
		if jump_index > 3:
			break

		var conductive_damage: int = target.status_manager.apply_conductive_damage(reaction.dot_dmg, jump_index)
		print("  -> Conductive jump ", jump_index, " to ", target.stats.character_name, " (Damage: ", conductive_damage, ")")
		target.take_damage(conductive_damage, false)
		target.status_manager.apply_status_effect(reaction)
		if reaction.base_stun_chance > 0.0 and randf() < reaction.base_stun_chance:
			var stun_effect = StatusEffect.new()
			stun_effect.is_stunned = true
			stun_effect.duration_turns = 1
			target.status_manager.apply_status_effect(stun_effect)
			print("  -> CONDUCTIVE STUN on ", target.stats.character_name, "!")
		jump_index += 1

func _is_valid_aoe_target(target: Battler, initial_targets: Array[Battler]) -> bool:
	return target.current_hp > 0 and target not in initial_targets
#endregion

#region Healing
func _on_battler_request_ally_heal(amount: int, is_enemy: bool) -> void:
	var target_party = enemy_active_party if is_enemy else player_active_party
	var lowest_hp_battler: Battler = null
	var lowest_hp_percentage: float = 100.0

	for battler in target_party:
		if battler.current_hp > 0:
			var hp_percent = float(battler.current_hp) / float(battler.stats.max_hp)
			if hp_percent < lowest_hp_percentage:
				lowest_hp_percentage = hp_percent
				lowest_hp_battler = battler

	if lowest_hp_battler != null:
		lowest_hp_battler.current_hp += amount
		lowest_hp_battler.current_hp = min(lowest_hp_battler.current_hp, lowest_hp_battler.stats.max_hp)
		lowest_hp_battler.emit_signal("health_changed", lowest_hp_battler.current_hp)
		print("MUTATION TRIGGERED: ", lowest_hp_battler.stats.character_name, " was healed for ", amount, " HP!")

#endregion

#region Battle Tester
func run_test_battle() -> void:
	print("\n==================================")
	print("   STARTING COMBAT SIMULATION   ")
	print("==================================\n")

	var hero = player_party[0]
	var slime = enemy_active_party[0] if enemy_active_party.size() > 0 else enemy_party[0]

	print("--- TEST 1: Equipment, Slash Weakness, and Crits ---")
	var hero_attack = hero.get_basic_attack()
	execute_move(hero, hero_attack, slime)

	print("\n--- TEST 2: Magic & Elemental Primers ---")
	if hero.skills_list.size() > 0:
		var hero_spell = hero.skills_list[0]
		execute_move(hero, hero_spell, slime)
#endregion
