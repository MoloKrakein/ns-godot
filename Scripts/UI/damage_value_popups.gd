extends Control
class_name DamageValuePopups

@export var popup_lifetime: float = 0.9
@export var float_up_distance: float = 28.0
@export var popup_offset: Vector2 = Vector2(-18.0, -72.0)

@onready var root_panel: Control = $Root
@onready var damage_value_label: Label = $Root/dmg_value
@onready var target_current_health: ProgressBar = $Root/StatsBar_Root/Bg/Bars_Root/Target_current_health
@onready var target_current_down_meter: ProgressBar = $Root/StatsBar_Root/Bg/Bars_Root/Target_current_DownMeter
@onready var weak_root: Control = $Root/DamageType_Root/Weak_Root
@onready var critical_root: Control = $Root/DamageType_Root/Critical_Root
@onready var resist_root: Control = $Root/DamageType_Root/Resist_Root
@onready var block_root: Control = $Root/DamageType_Root/Block_Root

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

func set_hit_type(is_weakness: bool, is_critical: bool, is_resist: bool=false, is_block: bool=false) -> void:
    if weak_root != null:
        weak_root.visible = is_weakness
    if critical_root != null:
        critical_root.visible = is_critical
    if resist_root != null:
        resist_root.visible = is_resist
    if block_root != null:
        block_root.visible = is_block

func bind_damage_popup(value: int, current_hp: int, max_hp: int, current_down_meter: int, max_down_meter: int, is_weakness: bool, is_critical: bool, is_resist: bool=false, is_block: bool=false) -> void:
    set_damage_value(value)
    set_target_health(current_hp, max_hp)
    set_target_down_meter(current_down_meter, max_down_meter)
    set_hit_type(is_weakness, is_critical, is_resist, is_block)

func play_popup(value: int, current_hp: int, max_hp: int, current_down_meter: int, max_down_meter: int, is_weakness: bool, is_critical: bool, is_resist: bool=false, is_block: bool=false, screen_position: Vector2 = Vector2.ZERO) -> void:
    bind_damage_popup(value, current_hp, max_hp, current_down_meter, max_down_meter, is_weakness, is_critical, is_resist, is_block)
    root_panel.position = screen_position + popup_offset
    visible = true
    modulate.a = 1.0
    var start_position: Vector2 = root_panel.position
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "modulate:a", 0.0, popup_lifetime)
    tween.tween_property(root_panel, "position:y", start_position.y - float_up_distance, popup_lifetime)
    await get_tree().create_timer(popup_lifetime).timeout
    queue_free()

func reset_popup() -> void:
    if damage_value_label != null:
        damage_value_label.text = "0"
    set_target_health(0, 1)
    set_target_down_meter(0, 100)
    set_hit_type(false, false)
