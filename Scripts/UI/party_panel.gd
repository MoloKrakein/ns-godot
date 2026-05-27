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
	if hp_value_label == null or mana_value_label == null or hp_bar == null or mana_bar == null or down_meter_bar == null:
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


func _on_battler_health_changed(_new_hp: int) -> void:
	_refresh_panel()


func _on_battler_mana_changed(_new_mp: int) -> void:
	_refresh_panel()


func _on_battler_ui_state_changed() -> void:
	_refresh_panel()


func _on_battler_downed(_downed_battler: Battler) -> void:
	_refresh_panel()