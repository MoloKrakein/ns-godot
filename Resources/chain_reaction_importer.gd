@tool
extends Node

# --- CONFIGURATION ---
@export var json_file_path: String = "res://reactions.json"
@export var output_directory: String = "res://Resources/Reactions/"

# Clickable checkbox in the Godot Inspector
@export var run_importer: bool = false:
	set(value):
		if value:
			_import_json()
			run_importer = false # Reset the button immediately

func _import_json():
	print("--- Starting JSON Import ---")
	
	if not FileAccess.file_exists(json_file_path): 
		print("ERROR: Could not find JSON at ", json_file_path)
		return
		
	# Ensure output directory exists (make sure path ends with a slash)
	if output_directory.ends_with("/") == false:
		output_directory += "/"
	if not DirAccess.dir_exists_absolute(output_directory):
		DirAccess.make_dir_recursive_absolute(output_directory)
		
	# 1. Read the whole file as text
	var file_string = FileAccess.get_file_as_string(json_file_path)
	
	# 2. Parse it into a Godot Array of Dictionaries
	var parsed_data = JSON.parse_string(file_string)
	
	if parsed_data == null or typeof(parsed_data) != TYPE_ARRAY:
		print("ERROR: Invalid JSON format. Make sure the file starts with [ and ends with ]")
		return
		
	# 3. Loop through every reaction in the JSON
	for data in parsed_data:
		var new_reaction = StatusEffect.new()

		new_reaction.id = data.get("id", "")
		new_reaction.effect_name = data.get("name", "")
		new_reaction.description = data.get("description", "")
		new_reaction.effect_type = data.get("effect_type", 1)
		new_reaction.duration_turns = data.get("duration_turns", 1)
		new_reaction.is_chain_reaction = data.get("is_chain_reaction", true)

		# Supports multiple recipes for one chain reaction.
		# Accepted JSON forms:
		# 1) "reaction_recipes": [{"primer": 1, "trigger": 2}, ...]
		# 2) "reaction_recipes": [[1, 2], ...]
		if data.has("reaction_recipes") and typeof(data["reaction_recipes"]) == TYPE_ARRAY:
			for recipe in data["reaction_recipes"]:
				if typeof(recipe) == TYPE_DICTIONARY:
					if recipe.has("primer") and recipe.has("trigger"):
						new_reaction.reaction_recipes.append(Vector2i(int(recipe["primer"]), int(recipe["trigger"])))
				elif typeof(recipe) == TYPE_ARRAY and recipe.size() >= 2:
					new_reaction.reaction_recipes.append(Vector2i(int(recipe[0]), int(recipe[1])))

		if data.has("reaction_primer"):
			new_reaction.reaction_primer = int(data.get("reaction_primer", 0))
			new_reaction.reaction_trigger = int(data.get("reaction_trigger", 0))

		# Damage block
		if data.has("damage"):
			var dmg = data["damage"]
			new_reaction.dot_dmg = int(dmg.get("dot_dmg", 0))
			new_reaction.heals_lowest_ally_per_turn = int(dmg.get("heals_lowest_ally", 0))
			new_reaction.heal_attacker_mp = int(dmg.get("heals_attacker_mp", 0))
			new_reaction.down_meter_fill_per_turn = int(dmg.get("down_meter_fill", 0))

		# Locks / flags
		if data.has("locks"):
			var locks = data["locks"]
			new_reaction.is_stunned = bool(locks.get("is_stunned", false))
			new_reaction.guarantees_next_crit = bool(locks.get("guarantees_crit", false))
			new_reaction.locks_magic = bool(locks.get("locks_magic", false))
			new_reaction.locks_physical = bool(locks.get("locks_physical", false))
			# disables_dodge is future/planned
			new_reaction.disables_healing = bool(locks.get("disables_healing", false))
			new_reaction.clears_all_statuses = bool(locks.get("clears_statuses", false))

		# Stat multipliers: JSON uses multiplicative factors (1 = no change). Convert to StatusEffect's delta format.
		if data.has("stat_multipliers"):
			var m = data["stat_multipliers"]
			new_reaction.stat_mult_defense = float(m.get("defense", 1.0)) - 1.0
			new_reaction.stat_mult_magic = float(m.get("magic", 1.0)) - 1.0
			new_reaction.stat_mult_strength = float(m.get("strength", 1.0)) - 1.0
			new_reaction.stat_mult_accuracy = float(m.get("accuracy", 1.0)) - 1.0

		# Macro / extra flags
		if data.has("macro"):
			var macro = data["macro"]
			new_reaction.chance_friendly_fire = float(macro.get("causes_friendly_fire", 0.0))
			new_reaction.flips_weaknesses = bool(macro.get("randomizes_weakness", false))
			# spreads_radium_on_down, scales_with_debuffs, changes_turn_queue are future/planned
			new_reaction.is_conductive = bool(macro.get("is_conductive", false))
			new_reaction.decay_per_jump = float(macro.get("decay_per_jump", 0.0))
			new_reaction.base_stun_chance = float(macro.get("base_stun_chance", 0.0))

		# Additional optional mappings (best-effort)
		# is_aoe, affects_self_and_targets are future/planned
		new_reaction.applies_to_all_enemies = bool(data.get("applies_to_all_enemies", false))
		new_reaction.applies_to_all_allies = bool(data.get("applies_to_all_allies", false))
		# removes_buffs, add_random_nerfs, mp_steal_amount, true_damage_multiplier, is_true_damage are future/planned
		new_reaction.removes_on_physical_hit = bool(data.get("removes_on_physical_hit", false))
		new_reaction.removes_on_magic_hit = bool(data.get("removes_on_magic_hit", false))
		# spreads_on_down_to_party, spreads_when_down, steals_stats are future/planned
		

		# 4. Save to hard drive as .tres
		var save_id = new_reaction.id if new_reaction.id != "" else new_reaction.effect_name.replace(" ", "_")
		var save_path = output_directory + save_id + ".tres"
		var error = ResourceSaver.save(new_reaction, save_path)

		if error == OK:
			print("Successfully generated: ", save_path)
		else:
			print("Error saving: ", save_path, " (err=", error, ")")
			
	print("--- JSON Import Complete! ---")
