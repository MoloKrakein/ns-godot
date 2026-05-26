extends RefCounted
class_name UIIconLibrary

const ELEMENT_BACKGROUND_FILL_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/starbg.svg")
const ELEMENT_BACKGROUND_STROKE_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/starbg_stroke.svg")
const FIRE_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Fire.svg")
const EARTH_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Earth.svg")
const LIGHT_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Light.svg")
const DARK_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Dark.svg")
const PHYSICAL_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Physical.svg")
const HEAL_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Heal.svg")
const BUFF_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Buff.svg")
const DEBUFF_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Debuff.svg")
const MULTI_FIRE_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Fire.svg")
const MULTI_EARTH_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Earth.svg")
const MULTI_LIGHT_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Light.svg")
const MULTI_DARKNESS_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Darkness.svg")
const MULTI_PHYSICAL_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Physical.svg")
const MULTI_HEAL_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Heal.svg")
const MULTI_BUFF_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Buff.svg")
const MULTI_DEBUFF_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Multi_icons/M_Debuff.svg")

const FIRE_BACKGROUND_FILL: Color = Color("#D70C0F")
const FIRE_BACKGROUND_STROKE: Color = Color("#ECB726")
const EARTH_BACKGROUND_FILL: Color = Color("#00FF11")
const EARTH_BACKGROUND_STROKE: Color = Color("#007D08")
const LIGHT_BACKGROUND_FILL: Color = Color("#FFF700")
const LIGHT_BACKGROUND_STROKE: Color = Color("#737000")
const DARK_BACKGROUND_FILL: Color = Color("#270136")
const DARK_BACKGROUND_STROKE: Color = Color("#600AD6")
const PHYSICAL_BACKGROUND_FILL: Color = Color("#686868")
const PHYSICAL_BACKGROUND_STROKE: Color = Color("#262525")
const HEAL_BACKGROUND_FILL: Color = Color("#FF33BB")
const HEAL_BACKGROUND_STROKE: Color = Color("#771717")
const BUFF_BACKGROUND_FILL: Color = Color("#71AAFF")
const BUFF_BACKGROUND_STROKE: Color = Color("#544EB2")
const DEBUFF_BACKGROUND_FILL: Color = Color("#544EB2")
const DEBUFF_BACKGROUND_STROKE: Color = Color("#71AAFF")

static func create_generic_style(key: StringName, icon_texture: Texture2D = null, background_texture: Texture2D = null, show_background: bool = true) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = key
	style.icon_texture = icon_texture
	style.background_fill_texture = background_texture
	style.use_background = show_background
	return style

static func create_move_style(move: BattleMove) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	var use_multi_icon: bool = _is_multi_target(move)
	style.key = move.get_icon_key()
	style.icon_texture = _resolve_move_icon_texture(move)
	style.background_fill_texture = ELEMENT_BACKGROUND_FILL_TEXTURE
	style.background_stroke_texture = ELEMENT_BACKGROUND_STROKE_TEXTURE
	style.use_background = true
	style.background_fill_color = PHYSICAL_BACKGROUND_FILL
	style.background_stroke_color = PHYSICAL_BACKGROUND_STROKE
	style.background_modulate = PHYSICAL_BACKGROUND_FILL

	if _apply_support_background_style(style, move, use_multi_icon):
		pass
	elif move.is_magic and move.element != GlobalData.Element.NEUTRAL:
		match move.element:
			GlobalData.Element.FIRE:
				if use_multi_icon:
					style.background_fill_color = Color("#FF2626")
					style.background_stroke_color = FIRE_BACKGROUND_FILL
					style.background_modulate = Color("#FF2626")
				else:
					style.background_fill_color = FIRE_BACKGROUND_FILL
					style.background_stroke_color = FIRE_BACKGROUND_STROKE
					style.background_modulate = FIRE_BACKGROUND_FILL
			GlobalData.Element.EARTH:
				_set_background_colors(style, EARTH_BACKGROUND_FILL, EARTH_BACKGROUND_STROKE, use_multi_icon)
			GlobalData.Element.LIGHT:
				_set_background_colors(style, LIGHT_BACKGROUND_FILL, LIGHT_BACKGROUND_STROKE, use_multi_icon)
			GlobalData.Element.DARK:
				_set_background_colors(style, DARK_BACKGROUND_FILL, DARK_BACKGROUND_STROKE, use_multi_icon)
	elif not move.is_magic and move.physical_type != GlobalData.PhysicalType.NONE:
		_set_background_colors(style, PHYSICAL_BACKGROUND_FILL, PHYSICAL_BACKGROUND_STROKE, use_multi_icon)
	style.use_background = move.get_move_template() != BattleMove.MoveTemplate.UTILITY
	return style

static func _resolve_move_icon_texture(move: BattleMove) -> Texture2D:
	if move.icon != null:
		return move.icon

	if move.ui_icon_name != &"":
		var explicit_icon: Texture2D = _resolve_texture_from_key(move.ui_icon_name)
		if explicit_icon != null:
			return explicit_icon

	match move.get_move_template():
		BattleMove.MoveTemplate.HEAL:
			return _resolve_heal_icon(_is_multi_target(move))
		BattleMove.MoveTemplate.STATUS:
			return _resolve_status_icon(move, _is_multi_target(move))
		BattleMove.MoveTemplate.SUPPORT:
			return _resolve_support_icon(_is_multi_target(move))
		BattleMove.MoveTemplate.UTILITY:
			return _resolve_utility_icon(_is_multi_target(move))

	if move.is_magic and move.element != GlobalData.Element.NEUTRAL:
		return _resolve_element_icon(move.element, _is_multi_target(move))

	if not move.is_magic and move.physical_type != GlobalData.PhysicalType.NONE:
		return _resolve_physical_icon(_is_multi_target(move))

	return _resolve_template_icon(move.get_move_template(), _is_multi_target(move))

static func _is_multi_target(move: BattleMove) -> bool:
	return move.target_type == BattleMove.Target.ALL_ENEMIES or move.target_type == BattleMove.Target.ALL_ALLIES

static func _resolve_element_icon(element: GlobalData.Element, use_multi_icon: bool) -> Texture2D:
	match element:
		GlobalData.Element.FIRE:
			return MULTI_FIRE_ICON_TEXTURE if use_multi_icon else FIRE_ICON_TEXTURE
		GlobalData.Element.EARTH:
			return MULTI_EARTH_ICON_TEXTURE if use_multi_icon else EARTH_ICON_TEXTURE
		GlobalData.Element.LIGHT:
			return MULTI_LIGHT_ICON_TEXTURE if use_multi_icon else LIGHT_ICON_TEXTURE
		GlobalData.Element.DARK:
			return MULTI_DARKNESS_ICON_TEXTURE if use_multi_icon else DARK_ICON_TEXTURE
		_:
			return PHYSICAL_ICON_TEXTURE

static func _resolve_physical_icon(use_multi_icon: bool) -> Texture2D:
	return MULTI_PHYSICAL_ICON_TEXTURE if use_multi_icon else PHYSICAL_ICON_TEXTURE

static func _resolve_template_icon(template: BattleMove.MoveTemplate, use_multi_icon: bool) -> Texture2D:
	match template:
		BattleMove.MoveTemplate.HEAL:
			return _resolve_heal_icon(use_multi_icon)
		BattleMove.MoveTemplate.SUPPORT:
			return _resolve_support_icon(use_multi_icon)
		BattleMove.MoveTemplate.STATUS:
			return _resolve_status_icon(null, use_multi_icon)
		BattleMove.MoveTemplate.UTILITY:
			return _resolve_utility_icon(use_multi_icon)
		_:
			return _resolve_physical_icon(use_multi_icon)

static func _resolve_support_icon(use_multi_icon: bool) -> Texture2D:
	return MULTI_HEAL_ICON_TEXTURE if use_multi_icon else HEAL_ICON_TEXTURE

static func _resolve_heal_icon(use_multi_icon: bool) -> Texture2D:
	return MULTI_HEAL_ICON_TEXTURE if use_multi_icon else HEAL_ICON_TEXTURE

static func _resolve_status_icon(move: BattleMove, use_multi_icon: bool) -> Texture2D:
	if move != null and move.applied_status != null and move.applied_status.effect_type == StatusEffect.Type.BUFF:
		return MULTI_BUFF_ICON_TEXTURE if use_multi_icon else BUFF_ICON_TEXTURE
	return MULTI_DEBUFF_ICON_TEXTURE if use_multi_icon else DEBUFF_ICON_TEXTURE

static func _resolve_utility_icon(use_multi_icon: bool) -> Texture2D:
	return MULTI_EARTH_ICON_TEXTURE if use_multi_icon else EARTH_ICON_TEXTURE

static func _resolve_texture_from_key(icon_key: StringName) -> Texture2D:
	match icon_key:
		&"custom_texture":
			return null
		&"Heal", &"move_heal", &"template_heal_template":
			return HEAL_ICON_TEXTURE
		&"Buff", &"move_buff":
			return BUFF_ICON_TEXTURE
		&"Debuff", &"move_debuff":
			return DEBUFF_ICON_TEXTURE
		&"M_Heal":
			return MULTI_HEAL_ICON_TEXTURE
		&"M_Buff":
			return MULTI_BUFF_ICON_TEXTURE
		&"M_Debuff":
			return MULTI_DEBUFF_ICON_TEXTURE
		&"M_Fire", &"element_fire":
			return MULTI_FIRE_ICON_TEXTURE
		&"M_Earth", &"element_earth":
			return MULTI_EARTH_ICON_TEXTURE
		&"M_Light", &"element_light":
			return MULTI_LIGHT_ICON_TEXTURE
		&"M_Darkness", &"element_dark":
			return MULTI_DARKNESS_ICON_TEXTURE
		&"M_Physical":
			return MULTI_PHYSICAL_ICON_TEXTURE
		&"element_fire":
			return FIRE_ICON_TEXTURE
		&"element_earth":
			return EARTH_ICON_TEXTURE
		&"element_light":
			return LIGHT_ICON_TEXTURE
		&"element_dark":
			return DARK_ICON_TEXTURE
		&"physical_slash", &"physical_pierce", &"physical_strike", &"physical_bullet", &"physical_none":
			return PHYSICAL_ICON_TEXTURE
		&"template_attack_template", &"move_attack":
			return MULTI_PHYSICAL_ICON_TEXTURE
		&"template_status_template", &"move_status":
			return MULTI_DEBUFF_ICON_TEXTURE
		&"template_support_template", &"move_support":
			return MULTI_HEAL_ICON_TEXTURE
		&"template_utility_template", &"move_utility":
			return MULTI_EARTH_ICON_TEXTURE
		&"target_aoe":
			return MULTI_LIGHT_ICON_TEXTURE
		&"target_self":
			return MULTI_EARTH_ICON_TEXTURE
		&"Group":
			return LIGHT_ICON_TEXTURE
		&"ColorRect":
			return LIGHT_ICON_TEXTURE
		&"Sword":
			return PHYSICAL_ICON_TEXTURE
		&"Heart":
			return LIGHT_ICON_TEXTURE
		&"NodeInfo":
			return DARK_ICON_TEXTURE
		&"Tools":
			return EARTH_ICON_TEXTURE
		&"Node":
			return EARTH_ICON_TEXTURE
		_:
			return null

static func _set_background_colors(style: UIIconStyle, fill_color: Color, stroke_color: Color, use_multi_icon: bool) -> void:
	if use_multi_icon:
		style.background_fill_color = stroke_color
		style.background_stroke_color = fill_color
		style.background_modulate = stroke_color
		return

	style.background_fill_color = fill_color
	style.background_stroke_color = stroke_color
	style.background_modulate = fill_color

static func _apply_support_background_style(style: UIIconStyle, move: BattleMove, use_multi_icon: bool) -> bool:
	match move.get_move_template():
		BattleMove.MoveTemplate.HEAL:
			_set_background_colors(style, HEAL_BACKGROUND_FILL, HEAL_BACKGROUND_STROKE, use_multi_icon)
			return true
		BattleMove.MoveTemplate.STATUS:
			if move.applied_status != null and move.applied_status.effect_type == StatusEffect.Type.BUFF:
				_set_background_colors(style, BUFF_BACKGROUND_FILL, BUFF_BACKGROUND_STROKE, use_multi_icon)
			else:
				_set_background_colors(style, DEBUFF_BACKGROUND_FILL, DEBUFF_BACKGROUND_STROKE, use_multi_icon)
			return true
		BattleMove.MoveTemplate.SUPPORT:
			_set_background_colors(style, HEAL_BACKGROUND_FILL, HEAL_BACKGROUND_STROKE, use_multi_icon)
			return true
		_:
			return false

static func _load_texture_safe(resource_path: String) -> Texture2D:
	if resource_path.is_empty():
		return null
	if not ResourceLoader.exists(resource_path):
		return null

	var loaded_resource: Resource = load(resource_path)
	if loaded_resource is Texture2D:
		return loaded_resource as Texture2D
	return null

static func _create_colored_style(key: StringName, icon_texture: Texture2D, fill_color: Color, stroke_color: Color) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = key
	style.icon_texture = icon_texture
	style.background_fill_texture = ELEMENT_BACKGROUND_FILL_TEXTURE
	style.background_stroke_texture = ELEMENT_BACKGROUND_STROKE_TEXTURE
	style.use_background = true
	style.use_icon = true
	style.background_fill_color = fill_color
	style.background_stroke_color = stroke_color
	style.background_modulate = fill_color
	return style

static func create_item_style(item: Consumable) -> UIIconStyle:
	var custom_texture: Texture2D = _load_texture_safe(item.icon_path)
	if custom_texture != null:
		return _create_colored_style(StringName("item_%s" % item.id), custom_texture, LIGHT_BACKGROUND_FILL, LIGHT_BACKGROUND_STROKE)

	if item.heals_hp > 0 or item.heals_mp > 0 or item.cures_status:
		return _create_colored_style(StringName("item_%s" % item.id), LIGHT_ICON_TEXTURE, LIGHT_BACKGROUND_FILL, LIGHT_BACKGROUND_STROKE)
	if item.applied_debuff != null:
		return _create_colored_style(StringName("item_%s" % item.id), DARK_ICON_TEXTURE, DARK_BACKGROUND_FILL, DARK_BACKGROUND_STROKE)
	if item.applied_buff != null:
		return _create_colored_style(StringName("item_%s" % item.id), EARTH_ICON_TEXTURE, EARTH_BACKGROUND_FILL, EARTH_BACKGROUND_STROKE)

	return _create_colored_style(StringName("item_%s" % item.id), PHYSICAL_ICON_TEXTURE, PHYSICAL_BACKGROUND_FILL, PHYSICAL_BACKGROUND_STROKE)

static func create_equipment_style(equipment: Equipment) -> UIIconStyle:
	var icon_texture: Texture2D = PHYSICAL_ICON_TEXTURE
	var fill_color: Color = PHYSICAL_BACKGROUND_FILL
	var stroke_color: Color = PHYSICAL_BACKGROUND_STROKE

	if equipment.slot_type == Equipment.Slot.WEAPON:
		fill_color = FIRE_BACKGROUND_FILL
		stroke_color = FIRE_BACKGROUND_STROKE
	elif equipment.slot_type == Equipment.Slot.ARMOR:
		fill_color = EARTH_BACKGROUND_FILL
		stroke_color = EARTH_BACKGROUND_STROKE
	elif equipment.slot_type == Equipment.Slot.ACCESSORY:
		fill_color = LIGHT_BACKGROUND_FILL
		stroke_color = LIGHT_BACKGROUND_STROKE

	return _create_colored_style(StringName("equipment_%s" % equipment.id), icon_texture, fill_color, stroke_color)

static func create_element_style(element: GlobalData.Element) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = StringName("element_%s" % GlobalData.Element.keys()[element].to_lower())
	style.use_background = element != GlobalData.Element.NEUTRAL
	style.background_fill_texture = ELEMENT_BACKGROUND_FILL_TEXTURE
	style.background_stroke_texture = ELEMENT_BACKGROUND_STROKE_TEXTURE
	style.icon_modulate = Color(1, 1, 1, 1)

	match element:
		GlobalData.Element.FIRE:
			style.icon_texture = FIRE_ICON_TEXTURE
			style.background_fill_color = FIRE_BACKGROUND_FILL
			style.background_stroke_color = FIRE_BACKGROUND_STROKE
			style.background_modulate = FIRE_BACKGROUND_FILL
		GlobalData.Element.EARTH:
			style.icon_texture = EARTH_ICON_TEXTURE
			style.background_fill_color = EARTH_BACKGROUND_FILL
			style.background_stroke_color = EARTH_BACKGROUND_STROKE
			style.background_modulate = EARTH_BACKGROUND_FILL
		GlobalData.Element.LIGHT:
			style.icon_texture = LIGHT_ICON_TEXTURE
			style.background_fill_color = LIGHT_BACKGROUND_FILL
			style.background_stroke_color = LIGHT_BACKGROUND_STROKE
			style.background_modulate = LIGHT_BACKGROUND_FILL
		GlobalData.Element.DARK:
			style.icon_texture = DARK_ICON_TEXTURE
			style.background_fill_color = DARK_BACKGROUND_FILL
			style.background_stroke_color = DARK_BACKGROUND_STROKE
			style.background_modulate = DARK_BACKGROUND_FILL
			
	return style

static func create_physical_style() -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = &"physical"
	style.icon_texture = PHYSICAL_ICON_TEXTURE
	style.background_fill_texture = ELEMENT_BACKGROUND_FILL_TEXTURE
	style.background_stroke_texture = ELEMENT_BACKGROUND_STROKE_TEXTURE
	style.use_background = true
	style.background_fill_color = PHYSICAL_BACKGROUND_FILL
	style.background_stroke_color = PHYSICAL_BACKGROUND_STROKE
	style.background_modulate = PHYSICAL_BACKGROUND_FILL
	return style

static func create_reaction_style(reaction_id: String) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = StringName(reaction_id)
	style.icon_texture = DARK_ICON_TEXTURE
	style.background_fill_texture = ELEMENT_BACKGROUND_FILL_TEXTURE
	style.background_stroke_texture = ELEMENT_BACKGROUND_STROKE_TEXTURE
	style.use_background = reaction_id != ""
	style.background_fill_color = DARK_BACKGROUND_FILL
	style.background_stroke_color = DARK_BACKGROUND_STROKE
	style.background_modulate = DARK_BACKGROUND_FILL
	return style

static func create_status_style(status: StatusEffect) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = StringName(status.id)
	style.icon_texture = EARTH_ICON_TEXTURE
	style.background_fill_texture = ELEMENT_BACKGROUND_FILL_TEXTURE
	style.background_stroke_texture = ELEMENT_BACKGROUND_STROKE_TEXTURE
	style.use_background = true
	style.use_icon = true
	style.background_fill_color = EARTH_BACKGROUND_FILL
	style.background_stroke_color = EARTH_BACKGROUND_STROKE
	style.background_modulate = EARTH_BACKGROUND_FILL
	return style
