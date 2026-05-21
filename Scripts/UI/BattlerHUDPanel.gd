extends Control
class_name BattlerHUDPanel

# Assume we have export variables for UI nodes
# @export var hp_bar: ProgressBar
# @export var mp_bar: ProgressBar
# @export var name_label: Label
# @export var status_container: HBoxContainer
# @export var primer_icon: TextureRect

var _battler: Battler

func bind_battler(battler: Battler) -> void:
	if _battler != null:
		unbind_battler()
		
	_battler = battler
	
	# Connect signals
	if not _battler.health_changed.is_connected(on_health_changed):
		_battler.health_changed.connect(on_health_changed)
		
	if not _battler.mana_changed.is_connected(on_mana_changed):
		_battler.mana_changed.connect(on_mana_changed)
		
	if not _battler.primer_changed.is_connected(on_primer_changed):
		_battler.primer_changed.connect(on_primer_changed)
		
	if not _battler.adrenaline_changed.is_connected(on_adrenaline_changed):
		_battler.adrenaline_changed.connect(on_adrenaline_changed)
		
	if not _battler.status_manager.status_state_changed.is_connected(on_status_state_changed):
		_battler.status_manager.status_state_changed.connect(on_status_state_changed)
		
	# Initial snapshot sync
	sync_with_snapshot(_battler.get_ui_snapshot())

func unbind_battler() -> void:
	if _battler == null:
		return
		
	if _battler.health_changed.is_connected(on_health_changed):
		_battler.health_changed.disconnect(on_health_changed)
		
	if _battler.mana_changed.is_connected(on_mana_changed):
		_battler.mana_changed.disconnect(on_mana_changed)
		
	if _battler.primer_changed.is_connected(on_primer_changed):
		_battler.primer_changed.disconnect(on_primer_changed)
		
	if _battler.adrenaline_changed.is_connected(on_adrenaline_changed):
		_battler.adrenaline_changed.disconnect(on_adrenaline_changed)
		
	if _battler.status_manager.status_state_changed.is_connected(on_status_state_changed):
		_battler.status_manager.status_state_changed.disconnect(on_status_state_changed)
		
	_battler = null

func sync_with_snapshot(snapshot: Dictionary) -> void:
	# Update all visuals immediately using the snapshot dictionary
	on_health_changed(snapshot.get("hp", 0))
	on_mana_changed(snapshot.get("mp", 0))
	on_primer_changed(snapshot.get("primer_element", GlobalData.Element.NEUTRAL))
	on_adrenaline_changed(snapshot.get("adrenaline_active", false), snapshot.get("adrenaline_stacks", 0))
	on_status_state_changed()

func on_health_changed(new_hp: int) -> void:
	# if hp_bar: hp_bar.value = new_hp
	pass

func on_mana_changed(new_mp: int) -> void:
	# if mp_bar: mp_bar.value = new_mp
	pass

func on_primer_changed(element: GlobalData.Element) -> void:
	# Update primer icon based on element
	pass

func on_adrenaline_changed(is_active: bool, stacks: int) -> void:
	# Update adrenaline visual/glow
	pass

func on_status_state_changed() -> void:
	if _battler == null: return
	var statuses = _battler.status_manager.get_active_status()
	# Clear status_container children and add new icons based on 'statuses' array
	pass

func get_battler() -> Battler:
	return _battler
