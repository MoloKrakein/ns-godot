extends Control
class_name EnemyStatsPanel

@export var battler: Battler:
	set(value):
		bind_battler(value)

@export var battler_path: NodePath
@export var follow_target: bool = true
@export var screen_offset: Vector2 = Vector2(-96.0, -170.0)
@export var show_active_stats_debug: bool = false

# --- Core UI Nodes ---
@onready var hp_value_label: Label = $PanelRoot/NameRoot/Name
@onready var hp_bar: ProgressBar = $PanelRoot/BarsRoot/HpBar
@onready var down_bar: ProgressBar = $PanelRoot/BarsRoot/DownBar
@onready var affinity_panels: AffinityPanels = $AffinityPanelRoot/AffinityPanels
@onready var active_stats_root: Control = $StatsPanelRoot

# --- Stat Bar Main Group Containers ---
@onready var status_bar_container: HBoxContainer = $StatsPanelRoot/StatusBarRoots/StatusBar
@onready var status_bar_bg: Polygon2D = $StatsPanelRoot/StatusBar

# --- Elemental & Badge UI Slots ---
@onready var primer_icon_slot: UIIconSlot = $ElementalRoot/PrimerIconSlot/UIIconSlot
@onready var trigger_icon_slot: UIIconSlot = $ElementalRoot/TriggerIconSlot/UIIconSlot

# --- ATK Component Sub-Roots & Labels ---
@onready var atk_stat_root: Control = $StatsPanelRoot/StatusBarRoots/StatusBar/AtkStatRoot
@onready var atk_buff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/AtkStatRoot/BuffIcon
@onready var atk_debuff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/AtkStatRoot/DebuffIcon
@onready var m_atk_label: Label = $StatsPanelRoot/StatusBarRoots/StatusBar/AtkStatRoot/AtkMagicLabel
@onready var p_atk_label: Label = $StatsPanelRoot/StatusBarRoots/StatusBar/AtkStatRoot/AtkPhysicalLabel

# --- DEF Component Sub-Roots & Labels ---
@onready var def_stat_root: Control = $StatsPanelRoot/StatusBarRoots/StatusBar/DefStatRoot
@onready var def_buff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/DefStatRoot/BuffIcon
@onready var def_debuff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/DefStatRoot/DebuffIcon
@onready var m_def_label: Label = $StatsPanelRoot/StatusBarRoots/StatusBar/DefStatRoot/DefMagicLabel
@onready var p_def_label: Label = $StatsPanelRoot/StatusBarRoots/StatusBar/DefStatRoot/DefPhysicalLabel

# --- SPD Component Sub-Roots ---
@onready var speed_stat_root: Control = $StatsPanelRoot/StatusBarRoots/StatusBar/SpeedStatRoot
@onready var spd_buff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/SpeedStatRoot/BuffIcon
@onready var spd_debuff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/SpeedStatRoot/DebuffIcon
@onready var spd_label: Label = $StatsPanelRoot/StatusBarRoots/StatusBar/SpeedStatRoot/SpeedLabel

# --- DOWN Modifier Sub-Roots ---
@onready var down_stat_root: Control = $StatsPanelRoot/StatusBarRoots/StatusBar/DownStatRoot
@onready var down_buff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/DownStatRoot/BuffIcon
@onready var down_debuff_icon_rect: TextureRect = $StatsPanelRoot/StatusBarRoots/StatusBar/DownStatRoot/DebuffIcon
@onready var down_label: Label = $StatsPanelRoot/StatusBarRoots/StatusBar/DownStatRoot/DwnLabel

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
		if not _bound_battler.ui_state_changed.is_connected(_on_battler_ui_state_changed):
			_bound_battler.ui_state_changed.connect(_on_battler_ui_state_changed)
		if not _bound_battler.downed.is_connected(_on_battler_downed):
			_bound_battler.downed.connect(_on_battler_downed)

		if _bound_battler.status_manager != null:
			if not _bound_battler.status_manager.status_state_changed.is_connected(_on_status_state_changed):
				_bound_battler.status_manager.status_state_changed.connect(_on_status_state_changed)
			if not _bound_battler.status_manager.status_applied.is_connected(_on_status_applied):
				_bound_battler.status_manager.status_applied.connect(_on_status_applied)
			if not _bound_battler.status_manager.status_removed.is_connected(_on_status_removed):
				_bound_battler.status_manager.status_removed.connect(_on_status_removed)

		if _bound_battler.down_manager != null:
			if not _bound_battler.down_manager.down_meter_updated.is_connected(_on_down_meter_updated):
				_bound_battler.down_manager.down_meter_updated.connect(_on_down_meter_updated)
			_on_down_meter_updated(_bound_battler.down_manager.current_meter, _bound_battler.down_manager.max_meter)

	call_deferred("_refresh_panel")
	call_deferred("_update_elemental_and_status_icons")


func _unbind_battler() -> void:
	if _bound_battler == null:
		return

	if _bound_battler.health_changed.is_connected(_on_battler_health_changed):
		_bound_battler.health_changed.disconnect(_on_battler_health_changed)
	if _bound_battler.ui_state_changed.is_connected(_on_battler_ui_state_changed):
		_bound_battler.ui_state_changed.disconnect(_on_battler_ui_state_changed)
	if _bound_battler.downed.is_connected(_on_battler_downed):
		_bound_battler.downed.disconnect(_on_battler_downed)

	if affinity_panels != null:
		affinity_panels.battler = null

	_bound_battler = null
	_clear_ui_elements()


func _clear_ui_elements() -> void:
	if primer_icon_slot != null: primer_icon_slot.set_style(null)
	if trigger_icon_slot != null: trigger_icon_slot.set_style(null)
	if status_bar_container != null: status_bar_container.visible = false
	if status_bar_bg != null: status_bar_bg.visible = false


func _refresh_panel() -> void:
	if hp_value_label == null or hp_bar == null or down_bar == null or active_stats_root == null:
		return

	if _bound_battler == null or not is_instance_valid(_bound_battler) or _bound_battler.stats_manager == null:
		hp_value_label.text = "Monster (Unbound)"
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

	# 🔄 FIX: Don't forcefully hide the root layout folder when debug is off!
	active_stats_root.visible = true 
	
	if follow_target and _bound_battler != null and is_instance_valid(_bound_battler):
		# 🔄 FIX: Use global_position instead of local position to ignore container shifting!
		global_position = _bound_battler.get_global_transform_with_canvas().origin + screen_offset


func _process(_delta: float) -> void:
	if not follow_target or _bound_battler == null or not is_instance_valid(_bound_battler):
		return
	# 🔄 FIX: Keep tracking synchronized on global canvas coordinates!
	global_position = _bound_battler.get_global_transform_with_canvas().origin + screen_offset


func _update_elemental_and_status_icons() -> void:
	if _bound_battler == null or not is_instance_valid(_bound_battler) or _bound_battler.status_manager == null:
		_clear_ui_elements()
		return

	# ============================================================
	# 🧬 ELEMENTAL BADGE LOGIC
	# ============================================================
	var active_reaction = _bound_battler.status_manager.active_reactions
	
	if active_reaction != null:
		if primer_icon_slot != null:
			var p_elem = active_reaction.reaction_primer
			if p_elem == 0 and active_reaction.reaction_recipes.size() > 0:
				p_elem = active_reaction.reaction_recipes[0].x
			primer_icon_slot.set_style(UIIconLibrary.create_element_style(p_elem))
			primer_icon_slot.visible = true
			
		if trigger_icon_slot != null:
			trigger_icon_slot.set_style(UIIconLibrary.create_reaction_style(active_reaction.id))
			trigger_icon_slot.visible = true
	else:
		if primer_icon_slot != null:
			if _bound_battler.elemental_primer != GlobalData.Element.NEUTRAL:
				primer_icon_slot.set_style(UIIconLibrary.create_element_style(_bound_battler.elemental_primer))
				primer_icon_slot.visible = true
			else:
				primer_icon_slot.set_style(null)
				primer_icon_slot.visible = false
				
		if trigger_icon_slot != null:
			trigger_icon_slot.set_style(null)
			trigger_icon_slot.visible = false

	# ============================================================
	# 📊 DYNAMIC STAT MODIFIER SWEEP LOGIC
	# ============================================================
	var sm = _bound_battler.status_manager
	var str_mult = sm.get_stats_multiplier("strength")
	var mag_mult = sm.get_stats_multiplier("magic")
	var def_mult = sm.get_stats_multiplier("defense")
	var spd_mult = sm.get_stats_multiplier("speed")
	var dwn_mult = sm.get_down_meter_fill_multiplier()
	var has_zero_def = sm.has_zero_defense()

	var any_modified = (str_mult != 1.0 or mag_mult != 1.0 or def_mult != 1.0 or has_zero_def or spd_mult != 1.0 or dwn_mult != 1.0)
	
	# Only show the sub-bar items if there are active modifiers to see
	status_bar_container.visible = (any_modified or show_active_stats_debug)
	if status_bar_bg != null:
		status_bar_bg.visible = (any_modified or show_active_stats_debug)

	# --- 1. ATK STAT HOOKS ---
	var phys_atk_changed = (str_mult != 1.0)
	var mag_atk_changed = (mag_mult != 1.0)
	atk_stat_root.visible = (phys_atk_changed or mag_atk_changed or show_active_stats_debug)
	
	if atk_stat_root.visible:
		var is_atk_buff = (str_mult > 1.0 or mag_mult > 1.0)
		atk_buff_icon_rect.visible = is_atk_buff
		atk_debuff_icon_rect.visible = not is_atk_buff
		
		if phys_atk_changed and mag_atk_changed:
			m_atk_label.visible = true
			p_atk_label.visible = false
		elif mag_atk_changed:
			m_atk_label.visible = true
			p_atk_label.visible = false
		else:
			m_atk_label.visible = false
			p_atk_label.visible = true

	# --- 2. DEF STAT HOOKS ---
	def_stat_root.visible = (def_mult != 1.0 or has_zero_def or show_active_stats_debug)
	if def_stat_root.visible:
		var is_def_buff = (def_mult > 1.0 and not has_zero_def)
		def_buff_icon_rect.visible = is_def_buff
		def_debuff_icon_rect.visible = not is_def_buff
		
		m_def_label.visible = true
		p_def_label.visible = false

	# --- 3. SPEED STAT HOOKS ---
	speed_stat_root.visible = (spd_mult != 1.0 or show_active_stats_debug)
	if speed_stat_root.visible:
		var is_spd_buff = (spd_mult > 1.0)
		spd_buff_icon_rect.visible = is_spd_buff
		spd_debuff_icon_rect.visible = not is_spd_buff

	# --- 4. DOWN MODIFIER HOOKS ---
	down_stat_root.visible = (dwn_mult != 1.0 or show_active_stats_debug)
	if down_stat_root.visible:
		var is_dwn_debuff = (dwn_mult > 1.0)
		down_buff_icon_rect.visible = not is_dwn_debuff
		down_debuff_icon_rect.visible = is_dwn_debuff

	if down_label != null and _bound_battler.down_manager != null:
		down_label.text = "%d / %d" % [_bound_battler.down_manager.current_meter, _bound_battler.down_manager.max_meter]


# ============================================================
# 📡 SIGNAL BINDINGS
# ============================================================
func _on_battler_health_changed(_new_hp: int) -> void:
	_refresh_panel()

func _on_battler_ui_state_changed() -> void:
	_refresh_panel()

func _on_battler_downed(_battler: Battler) -> void:
	_refresh_panel()

func _on_status_state_changed() -> void:
	_update_elemental_and_status_icons()

func _on_status_applied(_effect) -> void:
	_update_elemental_and_status_icons()

func _on_status_removed(_effect) -> void:
	_update_elemental_and_status_icons()

func _on_down_meter_updated(current_down_meter, max_down_meter) -> void:
	if down_label != null:
		down_label.text = "%d / %d" % [current_down_meter, max_down_meter]