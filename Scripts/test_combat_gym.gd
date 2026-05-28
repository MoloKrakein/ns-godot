extends Control

@export var move_button_scene: PackedScene = preload("res://Scenes/UI/buttons/movebutton/button.tscn")
@export var party_panel_scene: PackedScene = preload("res://Scenes/UI/party_panel.tscn")

@export var battle_manager: Node
@export var damage_label: Label
@export var button_container: VBoxContainer
@export var skill_menu: SkillMenu
@export var target_button_container: VBoxContainer
@export var player_party_stats_label: Label
@export var enemy_party_stats_label: Label
@export var turn_manipulation_container: HBoxContainer
@export var turn_order_container: HBoxContainer
@export var last_move_used_label: Label


var player_party: Array[Battler] = []
var enemy_party: Array[Battler] = []
var player_party_panel: PartyPanel = null
var enemy_party_panel: PartyPanel = null
var current_actor: Battler = null
var pending_move: BattleMove = null
var pending_move_targets: Array[Battler] = []
var battle_finished: bool = false

# Load a few test moves from your Godot folders
# @export var fire_move: BattleMove # You can swap this to Electro if you want!
# @export var water_move: BattleMove

var combat_log: PackedStringArray = []

func _ready():
	if battle_manager == null or damage_label == null:
		push_error("Combat gym is missing inspector assignments for battle_manager or damage_label.")
		return

	if skill_menu == null and button_container == null:
		push_error("Combat gym needs either a SkillMenu reference or a legacy button_container.")
		return

	# 1. Grab the characters from the BattleManager
	player_party = battle_manager.player_party
	enemy_party = battle_manager.enemy_party

	if skill_menu != null and not skill_menu.move_selected.is_connected(_on_skill_menu_move_selected):
		skill_menu.move_selected.connect(_on_skill_menu_move_selected)

	_setup_gym_layout()
	_setup_party_panels()
	
	# 2. Connect the UI Label to the Slime's damage signal
	for battler in battle_manager.player_party + battle_manager.enemy_party:
		battler.damage_taken.connect(_on_any_battler_damage_taken.bind(battler))
		battler.health_changed.connect(_refresh_combat_ui)
		battler.primer_changed.connect(_refresh_combat_ui)
		battler.ui_state_changed.connect(_refresh_combat_ui)
	battle_manager.turn_started.connect(_on_turn_started)
	battle_manager.party_member_swapped.connect(_on_party_member_swapped)

	battle_manager.build_turn_queue()
	_build_turn_controls()
	_begin_flow()

func _setup_gym_layout() -> void:
	if damage_label == null:
		return

	damage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	damage_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	damage_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	damage_label.size_flags_vertical = Control.SIZE_EXPAND_FILL

	if button_container != null:
		button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button_container.add_theme_constant_override("separation", 6)

	if target_button_container != null:
		target_button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		target_button_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		target_button_container.add_theme_constant_override("separation", 6)

	if turn_manipulation_container != null:
		turn_manipulation_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		turn_manipulation_container.size_flags_vertical = Control.SIZE_FILL
		turn_manipulation_container.add_theme_constant_override("separation", 6)

	if turn_order_container != null:
		turn_order_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		turn_order_container.size_flags_vertical = Control.SIZE_FILL
		turn_order_container.add_theme_constant_override("separation", 6)

	if player_party_stats_label != null:
		player_party_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		player_party_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		player_party_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	if enemy_party_stats_label != null:
		enemy_party_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		enemy_party_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		enemy_party_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func _setup_party_panels() -> void:
	if party_panel_scene == null:
		push_warning("Combat gym has no party_panel_scene assigned.")
		return

	if player_party.size() > 0:
		player_party_panel = _create_party_panel(player_party[0], Vector2(20.0, 560.0), "PlayerPartyPanel")


func _create_party_panel(bound_battler: Battler, panel_position: Vector2, panel_name: String) -> PartyPanel:
	if bound_battler == null:
		return null

	var panel: PartyPanel = party_panel_scene.instantiate() as PartyPanel
	if panel == null:
		return null

	panel.name = panel_name
	add_child(panel)
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = panel_position
	panel.size = Vector2(191.0, 181.0)
	panel.bind_battler(bound_battler)
	return panel

func _build_turn_controls() -> void:
	if turn_manipulation_container == null:
		return
	for child in turn_manipulation_container.get_children():
		child.queue_free()
	_create_turn_control_button(turn_manipulation_container, "END TURN", _on_end_turn_pressed)
	_create_turn_control_button(turn_manipulation_container, "PLAYER OVERDRIVE", _on_toggle_player_overdrive_pressed)
	_create_turn_control_button(turn_manipulation_container, "ENEMY OVERDRIVE", _on_toggle_enemy_overdrive_pressed)
	_create_turn_control_button(turn_manipulation_container, "QUEUE", _on_dump_queue_pressed)
	_create_turn_control_button(turn_manipulation_container, "REACTIONS", _on_run_reaction_matrix_pressed)
	_create_turn_control_button(turn_manipulation_container, "RELOAD", _on_reload_battle_gym_pressed)

func _create_turn_control_button(container: Container, label: String, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = label
	container.add_child(btn)
	btn.pressed.connect(callback)

# --- BUTTON LOGIC ---

func _build_move_buttons():
	_clear_target_buttons()

	if skill_menu != null:
		skill_menu.clear_moves()

	if button_container != null and skill_menu == null:
		for c in button_container.get_children():
			c.queue_free() # Clear out old buttons if they exist

	if current_actor == null or battle_finished:
		return

	if skill_menu != null:
		skill_menu.populate_for_battler(current_actor)
		return

	if current_actor.basic_atk != null:
		_create_button_for_move(current_actor.basic_atk)

	for skill in current_actor.skills_list:
		if skill != null:
			_create_button_for_move(skill)

func _on_end_turn_pressed():
	if battle_finished:
		return
	if current_actor != null:
		battle_manager.reschedule_battler_turn(current_actor)
	pending_move = null
	pending_move_targets.clear()
	_clear_target_buttons()
	_advance_turn_flow()

func _on_toggle_player_overdrive_pressed() -> void:
	var current = battle_manager.overdrive_parties.get(false, false)
	battle_manager.set_party_overdrive(false, not current)
	_update_ui_text("Player Overdrive toggled.", 0, false, false)

func _on_toggle_enemy_overdrive_pressed() -> void:
	var current = battle_manager.overdrive_parties.get(true, false)
	battle_manager.set_party_overdrive(true, not current)
	_update_ui_text("Enemy Overdrive toggled.", 0, false, false)

func _on_dump_queue_pressed() -> void:
	print("\n--- TURN QUEUE DUMP ---")
	for battler in battle_manager.turn_queue:
		print("- ", battler.stats.character_name, " | HP: ", battler.current_hp, " | SPD: ", battler.stats.speed)
	_refresh_combat_ui()

func _on_run_reaction_matrix_pressed() -> void:
	_test_all_reactions()
	_refresh_combat_ui()

func _on_reload_battle_gym_pressed() -> void:
	get_tree().reload_current_scene()

func _create_button_for_move(move: BattleMove):
	if button_container == null:
		return
	var btn: MoveButton = move_button_scene.instantiate()
	button_container.add_child(btn)
	btn.pressed.connect(func(): _execute_selected_move(move))
	btn.call_deferred("setup_move", move)

func _on_skill_menu_move_selected(move: BattleMove) -> void:
	_execute_selected_move(move)

func _execute_selected_move(move: BattleMove):
	if battle_finished or current_actor == null:
		return
	if not current_actor.can_use_move(move):
		print("Cannot use ", move.move_name)
		return

	if move.target_type == BattleMove.Target.SELF:
		battle_manager.execute_move(current_actor, move, current_actor)
		battle_manager.reschedule_battler_turn(current_actor, move)
		_update_last_move_label(move, current_actor, "SELF")
		_end_current_actor_turn()
		return

	pending_move = move
	_show_target_buttons(move)

func _show_target_buttons(move: BattleMove) -> void:
	_clear_target_buttons()
	var target_container: VBoxContainer = _get_target_button_container()
	if target_container == null:
		push_warning("No target button container is assigned; cannot show target selection UI.")
		return

	var valid_targets: Array[Battler] = _get_valid_targets_for_move(move)
	for target in valid_targets:
		var target_btn: Button = Button.new()
		target_btn.text = "Target: %s" % target.stats.character_name
		target_container.add_child(target_btn)
		target_btn.pressed.connect(func(): _execute_move_on_target(target))

func _execute_move_on_target(target: Battler) -> void:
	if battle_finished or current_actor == null or pending_move == null:
		return
	battle_manager.execute_move(current_actor, pending_move, target)
	battle_manager.reschedule_battler_turn(current_actor, pending_move)
	_update_last_move_label(pending_move, current_actor, target.stats.character_name)
	pending_move = null
	pending_move_targets.clear()
	_clear_target_buttons()
	_end_current_actor_turn()

func _clear_target_buttons() -> void:
	var target_container: VBoxContainer = _get_target_button_container()
	if target_container == null:
		return

	for child in target_container.get_children():
		if child is Button and child.text.begins_with("Target:"):
			child.queue_free()

func _get_target_button_container() -> VBoxContainer:
	if target_button_container != null:
		return target_button_container
	return button_container

func _get_valid_targets_for_move(move: BattleMove) -> Array[Battler]:
	var targets: Array[Battler] = []
	if current_actor == null:
		return targets
	var is_enemy_actor: bool = current_actor in battle_manager.enemy_party
	match move.target_type:
		BattleMove.Target.SINGLE_ENEMY, BattleMove.Target.ALL_ENEMIES:
			targets.append_array(battle_manager.get_active_party(not is_enemy_actor))
		BattleMove.Target.SINGLE_ALLY, BattleMove.Target.ALL_ALLIES:
			targets.append_array(battle_manager.get_active_party(is_enemy_actor))
		BattleMove.Target.SELF:
			targets.append(current_actor)
	return targets

func _begin_flow() -> void:
	battle_finished = false
	_advance_turn_flow()

func _advance_turn_flow() -> void:
	if battle_finished:
		return
	var battler: Battler = battle_manager.start_next_turn()
	if battler == null:
		_update_ui_text("Queue empty.", 0, false, false)
		return
	current_actor = battler
	if current_actor in battle_manager.enemy_party:
		if skill_menu != null:
			skill_menu.clear_moves()
		_clear_target_buttons()
		call_deferred("_auto_resolve_enemy_turn")
	else:
		_build_move_buttons()
		_refresh_combat_ui()

func _auto_resolve_enemy_turn() -> void:
	if battle_finished or current_actor == null:
		return
	var enemy_move: BattleMove = current_actor.basic_atk if current_actor.basic_atk != null else null
	if enemy_move == null and current_actor.skills_list.size() > 0:
		enemy_move = current_actor.skills_list[0]
	if enemy_move == null:
		battle_manager.reschedule_battler_turn(current_actor)
		_end_current_actor_turn()
		return
	var target_party: Array[Battler] = battle_manager.get_active_party(false if current_actor in battle_manager.enemy_party else true)
	var target: Battler = battle_manager.get_highest_threat_target(target_party)
	battle_manager.execute_move(current_actor, enemy_move, target)
	battle_manager.reschedule_battler_turn(current_actor, enemy_move)
	_update_last_move_label(enemy_move, current_actor, target.stats.character_name)
	_end_current_actor_turn()

func _end_current_actor_turn() -> void:
	_refresh_combat_ui()
	if battle_finished:
		return
	if battle_manager.check_party_downs():
		battle_finished = true
		_refresh_combat_ui()
		return
	call_deferred("_advance_turn_flow")

func _on_turn_started(active_battler: Battler) -> void:
	current_actor = active_battler
	# For the combat gym test: randomize each battler's equipped moves each turn (temporary)
	_randomize_equipped_moves()
	_refresh_combat_ui()


func _randomize_equipped_moves() -> void:
	# Randomly pick up to 5 moves from each battler's skills_list and assign to equipped_moves
	var all_battlers = battle_manager.player_party + battle_manager.enemy_party
	for b in all_battlers:
		if b == null:
			continue
		var pool: Array = []
		for m in b.skills_list:
			if m != null:
				pool.append(m)
		# also allow basic attack as a candidate
		if b.basic_atk != null:
			pool.append(b.basic_atk)
		if pool.size() == 0:
			b.equipped_moves = []
			continue
		var picks: Array = []
		var max_slots: int = min(5, pool.size())
		while picks.size() < max_slots and pool.size() > 0:
			var idx: int = int(randi()) % pool.size()
			picks.append(pool[idx])
			pool.remove_at(idx)
		b.set_equipped_moves(picks)
		# notify UI/state
		if b.has_method("emit_signal"):
			b.emit_signal("ui_state_changed")

func _on_party_member_swapped(_outgoing: Battler, _incoming: Battler, _is_enemy_party: bool) -> void:
	if player_party.size() > 0 and player_party_panel != null:
		player_party_panel.bind_battler(player_party[0])
	_refresh_combat_ui()

func _on_any_battler_damage_taken(_amount: int, _is_crit: bool, _is_weakness: bool, battler: Battler) -> void:
	if battler == enemy_party[0]:
		_update_ui_text("Slime took damage.", 0, _is_crit, _is_weakness)
	else:
		_refresh_combat_ui()

func _refresh_combat_ui(_unused: Variant = null) -> void:
	if enemy_party.size() == 0:
		return
	_refresh_party_labels()
	_refresh_turn_order()
	_update_ui_text("Combat Flow Active", 0, false, false)

func _refresh_party_labels() -> void:
	if player_party_stats_label != null:
		player_party_stats_label.text = _build_party_summary(player_party, "Player Party")
	if enemy_party_stats_label != null:
		enemy_party_stats_label.text = _build_party_summary(enemy_party, "Enemy Party")

func _build_party_summary(party: Array[Battler], title: String) -> String:
	var lines: PackedStringArray = [title]
	for battler in party:
		if battler == null:
			continue
		var primer_name: String = GlobalData.Element.keys()[battler.elemental_primer]
		var effects: Array[String] = []
		for s in battler.status_manager.active_status:
			effects.append(s.effect_name)
		if battler.status_manager.active_reactions != null:
			effects.append("[R] " + battler.status_manager.active_reactions.effect_name)
		var effects_str: String = "NONE"
		if effects.size() > 0:
			effects_str = ", ".join(effects)
		lines.append("%s | HP %d/%d | %s | %s" % [battler.stats.character_name, battler.current_hp, battler.stats_manager.get_active_max_hp(), primer_name, effects_str])
	return "\n".join(lines)

func _refresh_turn_order() -> void:
	if turn_order_container == null:
		return
	for child in turn_order_container.get_children():
		child.queue_free()

	var label := Label.new()
	label.text = "Turn Order"
	turn_order_container.add_child(label)

	for battler in battle_manager.turn_queue:
		var chip := Label.new()
		chip.text = "%s (AV %d)" % [battler.stats.character_name, battle_manager.get_battler_turn_action_value(battler)]
		turn_order_container.add_child(chip)

# --- UI VISUAL UPDATE ---

func _update_last_move_label(move: BattleMove, actor: Battler, target_info: String) -> void:
	if last_move_used_label == null:
		return
	var target_text: String = target_info if target_info != "SELF" and target_info != "ALL" else target_info
	last_move_used_label.text = "%s used %s → %s" % [actor.stats.character_name, move.move_name, target_text]

func _on_slime_damage_taken(amount: int, is_crit: bool, is_weakness: bool):
	var header = "Slime took " + str(amount) + " Damage!"
	_update_ui_text(header, amount, is_crit, is_weakness)

func _update_ui_text(header: String, _amount: int, is_crit: bool, is_weakness: bool):
	var pop_up_text = header
	
	if is_weakness:
		pop_up_text += "\n>> WEAKNESS HIT! <<"
	if is_crit:
		pop_up_text += "\n>> CRITICAL HIT! <<"
		
	pop_up_text += "\n\n--- BATTLE STATUS ---"
	for battler in battle_manager.player_party + battle_manager.enemy_party:
		var side_label: String = "Enemy" if battler in battle_manager.enemy_party else "Player"
		pop_up_text += "\n" + side_label + ": " + battler.stats.character_name
		pop_up_text += " | HP: " + str(battler.current_hp) + "/" + str(battler.stats_manager.get_active_max_hp())
		pop_up_text += " | Down: " + str(battler.down_manager.current_meter) + "/100"
		pop_up_text += " | Primer: " + GlobalData.Element.keys()[battler.elemental_primer]
		var curr_effects: Array[String] = []
		for s in battler.status_manager.active_status:
			curr_effects.append(s.effect_name)
		if battler.status_manager.active_reactions != null:
			curr_effects.append("[R] " + battler.status_manager.active_reactions.effect_name)
		pop_up_text += " | Effects: " + (", ".join(curr_effects) if curr_effects.size() > 0 else "NONE")
		if battler.status_manager.active_reactions != null:
			pop_up_text += " | Reaction: " + battler.status_manager.active_reactions.effect_name
		if battler.down_manager.is_downed:
			pop_up_text += " | DOWN"

	if current_actor != null:
		pop_up_text += "\n\nCurrent Turn: " + current_actor.stats.character_name
	else:
		pop_up_text += "\n\nCurrent Turn: NONE"

	if battle_finished:
		pop_up_text += "\nBattle State: FINISHED"
	
	damage_label.text = pop_up_text



func _test_all_reactions():
	print("\n--- RUNNING REACTION MATRIX TEST ---")
	var elements = GlobalData.Element.values()
	
	for primer in elements:
		for trigger in elements:
			# Skip neutral or same-element combos
			if primer == GlobalData.Element.NEUTRAL or trigger == GlobalData.Element.NEUTRAL or primer == trigger:
				continue
				
			var reaction = ItemDatabase.find_chain_reaction(primer, trigger)
			var p_name = GlobalData.Element.keys()[primer]
			var t_name = GlobalData.Element.keys()[trigger]
			
			if reaction != null:
				print(p_name, " + ", t_name, " = ", reaction.id)
			else:
				# Optional: Print combos that DON'T have a reaction yet
				# print(p_name, " + ", t_name, " = NO REACTION")
				pass
	print("--- TEST COMPLETE ---\n")
