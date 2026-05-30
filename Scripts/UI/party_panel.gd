extends Control
class_name PartyPanel

@export var battler: Battler:
	set(value):
		bind_battler(value)

@onready var hp_value_label: Label = $BGStar/NumVal/HpVal
@onready var mana_value_label: Label = $BGStar/NumVal/ManaVal
@onready var hp_bar: ProgressBar = $BGStar/StatBar/Background/HpBar
@onready var mana_bar: ProgressBar = $BGStar/StatBar/Background/MpBar
@onready var down_meter_bar: ProgressBar = $BGStar/StatBar/Background/MpBar2
@onready var active_stats_label: Label = $BGStar/ActiveStats

var _bound_battler: Battler = null


func _ready() -> void:
	_refresh_panel()


func bind_battler(new_battler: Battler) -> void:
	if _bound_battler == new_battler:
		_refresh_panel()
		return

	_unbind_battler()
	_bound_battler = new_battler
	battler = new_battler

	if _bound_battler != null:
		if not _bound_battler.health_changed.is_connected(_on_battler_health_changed):
			_bound_battler.health_changed.connect(_on_battler_health_changed)
		if not _bound_battler.mana_changed.is_connected(_on_battler_mana_changed):
			_bound_battler.mana_changed.connect(_on_battler_mana_changed)
		if not _bound_battler.ui_state_changed.is_connected(_on_battler_ui_state_changed):
			_bound_battler.ui_state_changed.connect(_on_battler_ui_state_changed)
		if not _bound_battler.downed.is_connected(_on_battler_downed):
			_bound_battler.downed.connect(_on_battler_downed)

	_refresh_panel()


func _unbind_battler() -> void:
	if _bound_battler == null:
		return

	if _bound_battler.health_changed.is_connected(_on_battler_health_changed):
		_bound_battler.health_changed.disconnect(_on_battler_health_changed)
	if _bound_battler.mana_changed.is_connected(_on_battler_mana_changed):
		_bound_battler.mana_changed.disconnect(_on_battler_mana_changed)
	if _bound_battler.ui_state_changed.is_connected(_on_battler_ui_state_changed):
		_bound_battler.ui_state_changed.disconnect(_on_battler_ui_state_changed)
	if _bound_battler.downed.is_connected(_on_battler_downed):
		_bound_battler.downed.disconnect(_on_battler_downed)

	_bound_battler = null


func _refresh_panel() -> void:
	if hp_value_label == null or mana_value_label == null or hp_bar == null or mana_bar == null or down_meter_bar == null or active_stats_label == null:
		return

	if _bound_battler == null or not is_instance_valid(_bound_battler):
		hp_value_label.text = "--/--"
		mana_value_label.text = "--/--"
		hp_bar.value = 0.0
		mana_bar.value = 0.0
		down_meter_bar.value = 0.0
		return

	var max_hp: int = _bound_battler.stats_manager.get_active_max_hp()
	var max_mp: int = _bound_battler.stats.max_mp
	var current_hp: int = _bound_battler.current_hp
	var current_mp: int = _bound_battler.current_mp
	var current_down_meter: int = _bound_battler.down_manager.current_meter
	var max_down_meter: int = _bound_battler.down_manager.max_meter

	hp_value_label.text = "%d/%d" % [current_hp, max_hp]
	mana_value_label.text = "%d/%d" % [current_mp, max_mp]
	hp_bar.max_value = float(max_hp)
	hp_bar.value = float(current_hp)
	mana_bar.max_value = float(max_mp)
	mana_bar.value = float(current_mp)
	down_meter_bar.max_value = float(max_down_meter)
	down_meter_bar.value = float(current_down_meter)

	var lines: PackedStringArray = PackedStringArray()
	lines.append(_format_stat_debug_line("HP", _bound_battler.stats_manager.get_stat_debug_breakdown("max_hp"), false, false))
	lines.append(_format_stat_debug_line("STR", _bound_battler.stats_manager.get_stat_debug_breakdown("strength"), false, false))
	lines.append(_format_stat_debug_line("MAG", _bound_battler.stats_manager.get_stat_debug_breakdown("magic"), false, false))
	lines.append(_format_stat_debug_line("PDEF", _bound_battler.stats_manager.get_stat_debug_breakdown("physical_def"), true, false))
	lines.append(_format_stat_debug_line("MDEF", _bound_battler.stats_manager.get_stat_debug_breakdown("magic_def"), true, false))
	lines.append(_format_stat_debug_line("SPD", _bound_battler.stats_manager.get_stat_debug_breakdown("speed"), false, false))
	lines.append(_format_stat_debug_line("LCK", _bound_battler.stats_manager.get_stat_debug_breakdown("luck"), false, false))
	lines.append(_format_stat_debug_line("CRT", _bound_battler.stats_manager.get_stat_debug_breakdown("crit_chance"), false, true))
	lines.append(_format_stat_debug_line("CDMG", _bound_battler.stats_manager.get_stat_debug_breakdown("crit_dmg"), false, true))
	active_stats_label.text = "\n".join(lines)


func _on_battler_health_changed(_new_hp: int) -> void:
	_refresh_panel()


func _on_battler_mana_changed(_new_mp: int) -> void:
	_refresh_panel()


func _on_battler_ui_state_changed() -> void:
	_refresh_panel()


func _on_battler_downed(_downed_battler: Battler) -> void:
	_refresh_panel()


func _format_stat_debug_line(label_name: String, breakdown: Dictionary, is_defense: bool, is_percentage: bool) -> String:
	var base_value: float = float(breakdown.get("base", 0.0))
	var equipment_bonus: float = float(breakdown.get("equipment", 0.0))
	var move_flat_bonus: float = float(breakdown.get("move_flat", 0.0))
	var move_pct_bonus: float = float(breakdown.get("move_pct", 0.0))
	var status_mult: float = float(breakdown.get("status_mult", 1.0))
	var extra_mult: float = float(breakdown.get("extra_mult", 1.0))
	var active_value: float = float(breakdown.get("active", 0.0))

	if is_percentage:
		return "%s %.2f (+%.2f eq, +%.2f move, x%.2f move%%, x%.2f = %.2f)" % [label_name, base_value, equipment_bonus, move_flat_bonus, 1.0 + move_pct_bonus, status_mult, active_value]

	if is_defense:
		return "%s %.0f (+%.0f eq, +%.0f move, x%.2f status, x%.2f adrenal = %.0f)" % [label_name, base_value, equipment_bonus, move_flat_bonus, status_mult, extra_mult, active_value]

	return "%s %.0f (+%.0f eq, +%.0f move, x%.2f = %.0f)" % [label_name, base_value, equipment_bonus, move_flat_bonus, status_mult, active_value]