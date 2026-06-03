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
@onready var down_bar: ProgressBar = $PanelRoot/StatusBar/BarsRoot/DownBar
@onready var affinity_panels: AffinityPanels = $AffinityPanelRoot/AffinityPanels
@onready var active_stats_root: Control = $StatsPanelRoot
@onready var primer_icon_slot: UIIconSlot = $ElementalRoot/PrimerIconSlot/UIIconSlot
@onready var trigger_icon_slot: UIIconSlot = $ElementalRoot/TriggerIconSlot/UIIconSlot
@onready var buff_icon_rect: TextureRect = $StatsPanelRoot/StatusBar/StatusBar/AtkStatRoot/BuffIcon
@onready var debuff_icon_rect: TextureRect = $StatsPanelRoot/StatusBar/StatusBar/AtkStatRoot/DebuffIcon
@onready var down_label: Label = $StatsPanelRoot/StatusBar/StatusBar/DownStatRoot/DwnLabel

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
		# if not _bound_battler.mana_changed.is_connected(_on_battler_mana_changed):
			# removed: use DownManager signals instead of mana_changed
		if not _bound_battler.ui_state_changed.is_connected(_on_battler_ui_state_changed):
			_bound_battler.ui_state_changed.connect(_on_battler_ui_state_changed)
		if not _bound_battler.downed.is_connected(_on_battler_downed):
			_bound_battler.downed.connect(_on_battler_downed)

		# Connect to status manager updates so buff/debuff and reactions update
		if _bound_battler.status_manager != null:
			if not _bound_battler.status_manager.status_state_changed.is_connected(_on_status_state_changed):
				_bound_battler.status_manager.status_state_changed.connect(_on_status_state_changed)
			if not _bound_battler.status_manager.status_applied.is_connected(_on_status_applied):
				_bound_battler.status_manager.status_applied.connect(_on_status_applied)
			if not _bound_battler.status_manager.status_removed.is_connected(_on_status_removed):
				_bound_battler.status_manager.status_removed.connect(_on_status_removed)

		# Connect down meter updates
		if _bound_battler.down_manager != null:
			if not _bound_battler.down_manager.down_meter_updated.is_connected(_on_down_meter_updated):
				_bound_battler.down_manager.down_meter_updated.connect(_on_down_meter_updated)
			# initialize down label immediately
			_on_down_meter_updated(_bound_battler.down_manager.current_meter, _bound_battler.down_manager.max_meter)

	# Defer refresh to avoid race where the Battler's onready children
	# (like `stats_manager`) may not be initialized yet.
	call_deferred("_refresh_panel")

	# Also update elemental/buff icons after deferred ready
	call_deferred("_update_elemental_and_status_icons")


func _unbind_battler() -> void:
	if _bound_battler == null:
		return

	if _bound_battler.health_changed.is_connected(_on_battler_health_changed):
		_bound_battler.health_changed.disconnect(_on_battler_health_changed)
	# removed: disconnect mana_changed (we use DownManager signals)
	if _bound_battler.ui_state_changed.is_connected(_on_battler_ui_state_changed):
		_bound_battler.ui_state_changed.disconnect(_on_battler_ui_state_changed)
	if _bound_battler.downed.is_connected(_on_battler_downed):
		_bound_battler.downed.disconnect(_on_battler_downed)

	if affinity_panels != null:
		affinity_panels.battler = null

	_bound_battler = null

	# Clear icons when unbound
	if primer_icon_slot != null:
		primer_icon_slot.set_style(null)
	if trigger_icon_slot != null:
		trigger_icon_slot.set_style(null)
	if buff_icon_rect != null:
		buff_icon_rect.visible = false
	if debuff_icon_rect != null:
		debuff_icon_rect.visible = false
	if down_label != null:
		down_label.text = ""


func _refresh_panel() -> void:
	if hp_value_label == null or hp_bar == null or down_bar == null or active_stats_root == null:
		return

	if _bound_battler == null or not is_instance_valid(_bound_battler) or _bound_battler.stats_manager == null:
		hp_value_label.text = "Monster"
		hp_bar.value = 0.0
		down_bar.value = 0.0
		return

	var max_hp: int = _bound_battler.stats_manager.get_active_max_hp()
	var max_down: int = _bound_battler.down_manager.max_meter if _bound_battler.down_manager != null else 100
	var current_hp: int = _bound_battler.current_hp
	var current_down: int = _bound_battler.down_manager.current_meter if _bound_battler.down_manager != null else 0

	hp_value_label.text = _bound_battler.stats.character_name
	hp_bar.max_value = float(max_hp)
	hp_bar.value = float(current_hp)
	down_bar.max_value = float(max_down)
	down_bar.value = float(current_down)

	active_stats_root.visible = show_active_stats_debug
	if follow_target and _bound_battler != null and is_instance_valid(_bound_battler):
		position = _bound_battler.get_global_transform_with_canvas().origin + screen_offset


func _on_battler_health_changed(_new_hp: int) -> void:
	_refresh_panel()


# mana_changed handler removed — down meter updates use DownManager signals


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


func _update_elemental_and_status_icons() -> void:
	if _bound_battler == null or not is_instance_valid(_bound_battler):
		if primer_icon_slot != null:
			primer_icon_slot.set_style(null)
		if trigger_icon_slot != null:
			trigger_icon_slot.set_style(null)
		if buff_icon_rect != null:
			buff_icon_rect.visible = false
		if debuff_icon_rect != null:
			debuff_icon_rect.visible = false
		if down_label != null:
			down_label.text = ""
		return

	# Primer icon
	if primer_icon_slot != null:
		var primer_style = UIIconLibrary.create_element_style(_bound_battler.elemental_primer)
		primer_icon_slot.set_style(primer_style)

	# Trigger / Reaction icon
	if trigger_icon_slot != null:
		var reaction = null
		if _bound_battler.status_manager != null:
			reaction = _bound_battler.status_manager.active_reactions
		if reaction != null:
			trigger_icon_slot.set_style(UIIconLibrary.create_reaction_style(reaction.id))
		else:
			trigger_icon_slot.set_style(null)

	# Buff / Debuff icons (show first of each type)
	var has_buff: bool = false
	var has_debuff: bool = false
	if _bound_battler.status_manager != null:
		var statuses: Array = _bound_battler.status_manager.get_active_status()
		for status in statuses:
			if not has_buff and status.effect_type == StatusEffect.Type.BUFF:
				if buff_icon_rect != null:
					buff_icon_rect.texture = UIIconLibrary.create_status_style(status).icon_texture
					buff_icon_rect.visible = true
				has_buff = true
			if not has_debuff and status.effect_type == StatusEffect.Type.DEBUFF:
				if debuff_icon_rect != null:
					debuff_icon_rect.texture = UIIconLibrary.create_status_style(status).icon_texture
					debuff_icon_rect.visible = true
				has_debuff = true
			if has_buff and has_debuff:
				break

	if not has_buff and buff_icon_rect != null:
		buff_icon_rect.visible = false
	if not has_debuff and debuff_icon_rect != null:
		debuff_icon_rect.visible = false

	# Down meter label
	if down_label != null and _bound_battler.down_manager != null:
		down_label.text = "%d / %d" % [_bound_battler.down_manager.current_meter, _bound_battler.down_manager.max_meter]


func _on_status_state_changed() -> void:
	_update_elemental_and_status_icons()


func _on_status_applied(effect) -> void:
	_update_elemental_and_status_icons()


func _on_status_removed(effect) -> void:
	_update_elemental_and_status_icons()


func _on_down_meter_updated(current_down_meter, max_down_meter) -> void:
	if down_label != null:
		down_label.text = "%d / %d" % [current_down_meter, max_down_meter]
