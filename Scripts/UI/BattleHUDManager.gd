extends Control
class_name BattleHUDManager

@export var player_panel_container: Control
@export var enemy_panel_container: Control
@export var battler_panel_scene: PackedScene # The scene with BattlerHUDPanel attached

var _active_panels: Dictionary = {} # Dictionary mapping Battler -> BattlerHUDPanel

func _ready() -> void:
	pass

func create_battler_panels(active_party: Array[Battler], is_enemy_party: bool) -> void:
	var container = enemy_panel_container if is_enemy_party else player_panel_container
	if container == null or battler_panel_scene == null:
		return
		
	# Clear existing panels for this party if any
	for child in container.get_children():
		child.queue_free()
		
	for battler in active_party:
		var panel = battler_panel_scene.instantiate() as BattlerHUDPanel
		if panel:
			container.add_child(panel)
			panel.bind_battler(battler)
			_active_panels[battler] = panel

func on_party_member_swapped(outgoing: Battler, incoming: Battler, is_enemy: bool) -> void:
	if _active_panels.has(outgoing):
		var panel = _active_panels[outgoing] as BattlerHUDPanel
		panel.unbind_battler()
		panel.bind_battler(incoming)
		
		# Update dictionary tracking
		_active_panels.erase(outgoing)
		_active_panels[incoming] = panel

func refresh_turn_order(turn_queue: Array[Battler]) -> void:
	# Implementation for updating visual turn order queue
	pass

func get_panel_for_battler(battler: Battler) -> BattlerHUDPanel:
	return _active_panels.get(battler)

func clear_all_panels() -> void:
	for battler in _active_panels:
		var panel = _active_panels[battler]
		if is_instance_valid(panel):
			panel.unbind_battler()
			panel.queue_free()
	_active_panels.clear()
