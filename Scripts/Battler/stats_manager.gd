extends Node
class_name StatsManager

@onready var battler= get_parent()

#region Equipment bonus
func get_equipped_items() -> Array[Equipment]:
	var equipped_items: Array[Equipment] = []
	if battler.equipped_weapon: equipped_items.append(battler.equipped_weapon)
	if battler.equipped_armor: equipped_items.append(battler.equipped_armor)
	if battler.equipped_accessory: equipped_items.append(battler.equipped_accessory)
	if battler.equipped_pant: equipped_items.append(battler.equipped_pant)
	if battler.equipped_shoe: equipped_items.append(battler.equipped_shoe)
	if battler.equipped_necktie: equipped_items.append(battler.equipped_necktie)
	return equipped_items

func get_eq_bonus_max_hp() -> int:
	var bonus = 0
	for item in get_equipped_items():
		bonus += item.bonus_max_hp
	return bonus

func get_eq_bonus_strength() -> int:
	var bonus = 0
	for item in get_equipped_items():
		bonus += item.bonus_strength
	return bonus

func get_eq_bonus_magic() -> int:
	var bonus = 0
	for item in get_equipped_items():
		bonus += item.bonus_magic
	return bonus

func get_eq_bonus_physical_def() -> int:
	var bonus = 0
	for item in get_equipped_items():
		bonus += item.bonus_physical_def
	return bonus

func get_eq_bonus_magic_def() -> int:
	var bonus = 0
	for item in get_equipped_items():
		bonus += item.bonus_magic_def
	return bonus

func get_eq_bonus_luck() -> int:
	var bonus = 0
	for item in get_equipped_items():
		bonus += item.bonus_luck
	return bonus

func get_eq_bonus_speed() -> int:
	var bonus = 0
	for item in get_equipped_items():
		bonus += item.bonus_speed
	return bonus

func get_eq_bonus_crit_chance() -> float:
	var bonus = 0.0
	for item in get_equipped_items():
		bonus += item.bonus_crit_rate
	return bonus

func get_eq_bonus_crit_dmg() -> float:
	var bonus = 0.0
	for item in get_equipped_items():
		bonus += item.bonus_crit_dmg
	return bonus

# Family of getters that combine base stats + equipment bonuses
func get_active_set_bonus() -> Array[String]:
	var families = []
	var active_bonuses: Array[String] = []
	for equipment in get_equipped_items():
		families.append(equipment.family)
	for family in families:
		if family != "None" and families.count(family) >= 2: # If we have 2 or more pieces of the same family equipped
			active_bonuses.append(family)
	return active_bonuses
#endregion



#region Active Stats Getters

func get_active_max_hp() -> int:
	return battler.stats.max_hp + get_eq_bonus_max_hp()

func get_active_strength() -> int:
	var total_strength = battler.stats.strength + get_eq_bonus_strength()
	var multiplier = battler.status_manager.get_stats_multiplier("strength")
	return max(0, roundi(total_strength * multiplier))
		
func get_active_magic() -> int:
	var total_magic = battler.stats.magic + get_eq_bonus_magic()
	var multiplier = battler.status_manager.get_stats_multiplier("magic")
	return max(0, roundi(total_magic * multiplier))

func get_active_def(is_magic: bool) -> int:
	if battler.status_manager.has_zero_defense():
		return 0
	var base_def = battler.stats.magic_def if is_magic else battler.stats.physical_def
	var eq_def = get_eq_bonus_magic_def() if is_magic else get_eq_bonus_physical_def()
	var total_def = base_def + eq_def

	var multiplier = battler.status_manager.get_stats_multiplier("defense")
	var adrenaline_multiplier = battler.get_adrenaline_defense_multiplier()
	return max(0, roundi(total_def * multiplier * adrenaline_multiplier))

func get_active_luck() -> int:
	return max(0, battler.stats.luck + get_eq_bonus_luck())

func get_active_speed() -> int:
	var total_speed = battler.stats.speed + get_eq_bonus_speed()
	var multiplier = battler.status_manager.get_stats_multiplier("speed")
	return max(0, roundi(total_speed * multiplier))

func get_active_crit_chance() -> float:
	var total_crit_rate = battler.stats.crit_rate 
	total_crit_rate += get_eq_bonus_crit_chance()
	total_crit_rate += (get_active_luck() / 1000.0)
	# Allow status effects (and active reactions) to modify crit chance via stat_mult_crit_chance
	if battler.status_manager:
		var crit_mult = battler.status_manager.get_stats_multiplier("crit_chance")
		total_crit_rate = total_crit_rate * crit_mult
	return total_crit_rate

func get_active_crit_dmg() -> float:
	var total_crit_dmg = 1.5 + battler.stats.crit_dmg 
	for equipment in get_equipped_items():
		if "bonus_crit_dmg" in equipment:
			total_crit_dmg += equipment.bonus_crit_dmg
		# Apply status effect crit damage multipliers
		if battler.status_manager:
			var crit_dmg_mult = battler.status_manager.get_stats_multiplier("crit_dmg")
			total_crit_dmg = total_crit_dmg * crit_dmg_mult
	return total_crit_dmg
#endregion
