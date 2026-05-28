extends Control
class_name DamageValuePopups

@onready var root_panel: Control = $Root
@onready var damage_value_label: Label = $Root/dmg_value
@onready var target_current_health: ProgressBar = $Root/StatsBar_Root/Bg/Bars_Root/Target_current_health
@onready var target_current_down_meter: ProgressBar = $Root/StatsBar_Root/Bg/Bars_Root/Target_current_DownMeter
@onready var weak_root: Control = $Root/DamageType_Root/Weak_Root
@onready var critical_root: Control = $Root/DamageType_Root/Critical_Root

func set_damage_value(value: int) -> void:
	if damage_value_label != null:
		damage_value_label.text = str(value)

func set_target_health(current_hp: int, max_hp: int) -> void:
	if target_current_health == null:
		return
	var max_value: float = float(max(1, max_hp))
	target_current_health.max_value = max_value
	target_current_health.value = clampf(float(current_hp), 0.0, max_value)

func set_target_down_meter(current_meter: int, max_meter: int = 100) -> void:
	if target_current_down_meter == null:
		return
	var max_value: float = float(max(1, max_meter))
	target_current_down_meter.max_value = max_value
	target_current_down_meter.value = clampf(float(current_meter), 0.0, max_value)

func set_hit_type(is_weakness: bool, is_critical: bool) -> void:
	if weak_root != null:
		weak_root.visible = is_weakness
	if critical_root != null:
		critical_root.visible = is_critical

func bind_damage_popup(value: int, current_hp: int, max_hp: int, current_down_meter: int, max_down_meter: int, is_weakness: bool, is_critical: bool) -> void:
	set_damage_value(value)
	set_target_health(current_hp, max_hp)
	set_target_down_meter(current_down_meter, max_down_meter)
	set_hit_type(is_weakness, is_critical)

func reset_popup() -> void:
	if damage_value_label != null:
		damage_value_label.text = "0"
	set_target_health(0, 1)
	set_target_down_meter(0, 100)
	set_hit_type(false, false)