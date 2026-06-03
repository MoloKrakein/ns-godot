extends Control
class_name EnemyStatsPanel

@export var battler: Battler:
	set(value):
		bind_battler(value)

@export var battler_path: NodePath
@export var follow_target: bool = true
@export var screen_offset: Vector2 = Vector2(-96.0, -170.0)
@export var show_active_stats_debug: bool = false

@onready var hp_value_label: Label = $PanelRoot/NameRoot/Name
@onready var hp_bar: ProgressBar = $PanelRoot/StatusBar/BarsRoot/HpBar
@onready var mana_bar: ProgressBar = $PanelRoot/StatusBar/BarsRoot/MpBar2
@onready var affinity_panels: AffinityPanels = $AffinityPanelRoot/AffinityPanels
@onready var active_stats_root: Control = $StatsPanelRoot

var _bound_battler: Battler = null


func _ready() -> void:
	if _bound_battler == null and battler_path != NodePath():
		var resolved_battler: Battler = get_node_or_null(battler_path) as Battler
		if resolved_battler != null:
			bind_battler(resolved_battler)
	elif _bound_battler == null and get_parent() is Battler:
		bind_battler(get_parent() as Battler)
	_refresh_panel()
	set_process(follow_target)


func bind_battler(new_battler: Battler) -> void:
	if _bound_battler == new_battler:
		_refresh_panel()
		return

	_unbind_battler()
	_bound_battler = new_battler
	battler = new_battler

	if affinity_panels != null:
		affinity_panels.battler = _bound_battler

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

	if affinity_panels != null:
		affinity_panels.battler = null

	_bound_battler = null


func _refresh_panel() -> void:
	if hp_value_label == null or hp_bar == null or mana_bar == null or active_stats_root == null:
		return

	if _bound_battler == null or not is_instance_valid(_bound_battler):
		hp_value_label.text = "Monster"
		hp_bar.value = 0.0
		mana_bar.value = 0.0
		return

	var max_hp: int = _bound_battler.stats_manager.get_active_max_hp()
	var max_mp: int = _bound_battler.stats.max_mp
	var current_hp: int = _bound_battler.current_hp
	var current_mp: int = _bound_battler.current_mp

	hp_value_label.text = _bound_battler.stats.character_name
	hp_bar.max_value = float(max_hp)
	hp_bar.value = float(current_hp)
	mana_bar.max_value = float(max_mp)
	mana_bar.value = float(current_mp)

	active_stats_root.visible = show_active_stats_debug
	if follow_target and _bound_battler != null and is_instance_valid(_bound_battler):
		position = _bound_battler.get_global_transform_with_canvas().origin + screen_offset


func _on_battler_health_changed(_new_hp: int) -> void:
	_refresh_panel()


func _on_battler_mana_changed(_new_mp: int) -> void:
	_refresh_panel()


func _on_battler_ui_state_changed() -> void:
	_refresh_panel()


func _on_battler_downed(_battler: Battler) -> void:
	_refresh_panel()


func _process(_delta: float) -> void:
	if not follow_target:
		return
	if _bound_battler == null or not is_instance_valid(_bound_battler):
		return
	position = _bound_battler.get_global_transform_with_canvas().origin + screen_offset
