extends Control
class_name AffinityPanels

@export var battler: Battler:
	set(value):
		bind_battler(value)

@export var weak_color: Color = Color("#00BDF2")
@export var normal_color: Color = Color("#29388A")
@export var resist_color: Color = Color("#771717")
@export var block_color: Color = Color("#57555B")

@onready var fire_bg_fill: Panel = $Root/FireRootIcons/BgFill
@onready var fire_bg_stroke: Panel = $Root/FireRootIcons/BgStroke
@onready var light_bg_fill: Panel = $Root/LightRootIcons/BgFill
@onready var light_bg_stroke: Panel = $Root/LightRootIcons/BgStroke
@onready var earth_bg_fill: Panel = $Root/EarthRootIcons/BgFill
@onready var earth_bg_stroke: Panel = $Root/EarthRootIcons/BgStroke
@onready var dark_bg_fill: Panel = $Root/DarkRootIcons/BgFill
@onready var dark_bg_stroke: Panel = $Root/DarkRootIcons/BgStroke
@onready var physical_bg_fill: Panel = $Root/PhysicalRootIcons/BgFill
@onready var physical_bg_stroke: Panel = $Root/PhysicalRootIcons/BgStroke

var _bound_battler: Battler = null


func _ready() -> void:
	_refresh_panel()


func bind_battler(new_battler: Battler) -> void:
	if _bound_battler == new_battler:
		_refresh_panel()
		return

	_bound_battler = new_battler
	battler = new_battler
	_refresh_panel()


func _refresh_panel() -> void:
	if fire_bg_fill == null or fire_bg_stroke == null or light_bg_fill == null or light_bg_stroke == null or earth_bg_fill == null or earth_bg_stroke == null or dark_bg_fill == null or dark_bg_stroke == null or physical_bg_fill == null or physical_bg_stroke == null:
		return

	if _bound_battler == null or not is_instance_valid(_bound_battler) or _bound_battler.affinity_manager == null:
		_apply_slot_color(fire_bg_fill, fire_bg_stroke, normal_color)
		_apply_slot_color(light_bg_fill, light_bg_stroke, normal_color)
		_apply_slot_color(earth_bg_fill, earth_bg_stroke, normal_color)
		_apply_slot_color(dark_bg_fill, dark_bg_stroke, normal_color)
		_apply_slot_color(physical_bg_fill, physical_bg_stroke, normal_color)
		return

	var affinity_manager: AffinityManager = _bound_battler.affinity_manager
	_apply_slot_color(fire_bg_fill, fire_bg_stroke, _get_affinity_color(affinity_manager.get_current_affinity(true, GlobalData.Element.FIRE)))
	_apply_slot_color(light_bg_fill, light_bg_stroke, _get_affinity_color(affinity_manager.get_current_affinity(true, GlobalData.Element.LIGHT)))
	_apply_slot_color(earth_bg_fill, earth_bg_stroke, _get_affinity_color(affinity_manager.get_current_affinity(true, GlobalData.Element.EARTH)))
	_apply_slot_color(dark_bg_fill, dark_bg_stroke, _get_affinity_color(affinity_manager.get_current_affinity(true, GlobalData.Element.DARK)))
	_apply_slot_color(physical_bg_fill, physical_bg_stroke, _get_affinity_color(affinity_manager.get_current_affinity(false, GlobalData.Element.NEUTRAL, GlobalData.PhysicalType.NONE)))


func _get_affinity_color(affinity: BattlerStats.Affinity) -> Color:
	match affinity:
		BattlerStats.Affinity.WEAK:
			return weak_color
		BattlerStats.Affinity.RESIST:
			return resist_color
		BattlerStats.Affinity.BLOCK:
			return block_color
		_:
			return normal_color


func _apply_slot_color(fill_panel: Panel, stroke_panel: Panel, color_value: Color) -> void:
	fill_panel.modulate = color_value
	stroke_panel.modulate = color_value