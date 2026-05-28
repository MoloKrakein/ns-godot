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

# --- Move-based bonuses
func get_equipped_moves() -> Array[BattleMove]:
	if not battler:
		return []
	if battler.equipped_moves == null:
		return []
	return battler.equipped_moves

func _sum_move_flat(stat_key: String) -> float:
	var total: float = 0.0
	for m in get_equipped_moves():
		if m == null:
			continue
		if m.stat_flat_bonus.has(stat_key):
			total += float(m.stat_flat_bonus[stat_key])
	return total

func _sum_move_pct(stat_key: String) -> float:
	var total: float = 0.0
	for m in get_equipped_moves():
		if m == null:
			continue
		if m.stat_pct_bonus.has(stat_key):
			total += float(m.stat_pct_bonus[stat_key])
	return total

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
	var base_hp = battler.stats.max_hp + get_eq_bonus_max_hp()
	base_hp += int(roundi(_sum_move_flat("max_hp")))
	var pct = 1.0 + _sum_move_pct("max_hp")
	# status multipliers (if present) should still apply
	var status_mult = 1.0
	if battler.status_manager:
		status_mult = battler.status_manager.get_stats_multiplier("max_hp")
	return max(1, roundi(float(base_hp) * pct * status_mult))

func get_active_strength() -> int:
	var total_strength = battler.stats.strength + get_eq_bonus_strength()
	# apply flat move bonuses
	total_strength += int(roundi(_sum_move_flat("strength")))
	# combine status multiplier with move percent bonuses
	var status_mult = battler.status_manager.get_stats_multiplier("strength")
	var move_pct = 1.0 + _sum_move_pct("strength")
	return max(0, roundi(float(total_strength) * status_mult * move_pct))
		
func get_active_magic() -> int:
	var total_magic = battler.stats.magic + get_eq_bonus_magic()
	total_magic += int(roundi(_sum_move_flat("magic")))
	var status_mult = battler.status_manager.get_stats_multiplier("magic")
	var move_pct = 1.0 + _sum_move_pct("magic")
	return max(0, roundi(float(total_magic) * status_mult * move_pct))

func get_active_def(is_magic: bool) -> int:
	if battler.status_manager.has_zero_defense():
		return 0
	var base_def = battler.stats.magic_def if is_magic else battler.stats.physical_def
	var eq_def = get_eq_bonus_magic_def() if is_magic else get_eq_bonus_physical_def()
	var total_def = base_def + eq_def
	# add move flat bonuses for specific defense types
	if is_magic:
		total_def += int(roundi(_sum_move_flat("magic_def")))
	else:
		total_def += int(roundi(_sum_move_flat("physical_def")))

	var multiplier = battler.status_manager.get_stats_multiplier("defense")
	var adrenaline_multiplier = battler.get_adrenaline_defense_multiplier()
	var move_pct = 1.0
	if is_magic:
		move_pct += _sum_move_pct("magic_def")
	else:
		move_pct += _sum_move_pct("physical_def")
	return max(0, roundi(float(total_def) * multiplier * adrenaline_multiplier * move_pct))

func get_active_luck() -> int:
	var total = battler.stats.luck + get_eq_bonus_luck()
	total += int(roundi(_sum_move_flat("luck")))
	var move_pct = 1.0 + _sum_move_pct("luck")
	return max(0, roundi(float(total) * move_pct))

func get_active_speed() -> int:
	var total_speed = battler.stats.speed + get_eq_bonus_speed()
	total_speed += int(roundi(_sum_move_flat("speed")))
	var status_mult = battler.status_manager.get_stats_multiplier("speed")
	var move_pct = 1.0 + _sum_move_pct("speed")
	return max(0, roundi(float(total_speed) * status_mult * move_pct))

func get_active_crit_chance() -> float:
	var total_crit_rate = battler.stats.crit_rate
	total_crit_rate += get_eq_bonus_crit_chance()
	# move flat and pct (pct applied multiplicatively after status mult)
	total_crit_rate += _sum_move_flat("crit_chance")
	total_crit_rate += (get_active_luck() / 1000.0)
	var status_mult = 1.0
	if battler.status_manager:
		status_mult = battler.status_manager.get_stats_multiplier("crit_chance")
	var move_pct = 1.0 + _sum_move_pct("crit_chance")
	return total_crit_rate * status_mult * move_pct

func get_active_crit_dmg() -> float:
	var total_crit_dmg = 1.5 + battler.stats.crit_dmg
	# equipment
	for equipment in get_equipped_items():
		if "bonus_crit_dmg" in equipment:
			total_crit_dmg += equipment.bonus_crit_dmg
	# move flat
	total_crit_dmg += _sum_move_flat("crit_dmg")
	# status multipliers
	var status_mult = 1.0
	if battler.status_manager:
		status_mult = battler.status_manager.get_stats_multiplier("crit_dmg")
	# move pct
	var move_pct = 1.0 + _sum_move_pct("crit_dmg")
	return total_crit_dmg * status_mult * move_pct
#endregion
