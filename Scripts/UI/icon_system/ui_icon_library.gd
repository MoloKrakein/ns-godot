extends RefCounted
class_name UIIconLibrary

const ELEMENT_BACKGROUND_FILL_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/starbg.svg")
const ELEMENT_BACKGROUND_STROKE_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/starbg_stroke.svg")
const FIRE_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Fire.svg")
const EARTH_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Earth.svg")
const LIGHT_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Light.svg")
const DARK_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Dark.svg")
const PHYSICAL_ICON_TEXTURE: Texture2D = preload("res://Arts/UI/Icons/Icons/Physical.svg")

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

static func create_generic_style(key: StringName, icon_texture: Texture2D = null, background_texture: Texture2D = null, show_background: bool = true) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = key
	style.icon_texture = icon_texture
	style.background_fill_texture = background_texture
	style.use_background = show_background
	return style

static func create_move_style(move: BattleMove) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = move.get_icon_key()
	style.icon_texture = _resolve_move_icon_texture(move)
	style.background_fill_texture = ELEMENT_BACKGROUND_FILL_TEXTURE
	style.background_stroke_texture = ELEMENT_BACKGROUND_STROKE_TEXTURE
	style.use_background = true
	style.background_fill_color = PHYSICAL_BACKGROUND_FILL
	style.background_stroke_color = PHYSICAL_BACKGROUND_STROKE
	style.background_modulate = PHYSICAL_BACKGROUND_FILL

	if move.is_magic and move.element != GlobalData.Element.NEUTRAL:
		match move.element:
			GlobalData.Element.FIRE:
				style.background_fill_color = FIRE_BACKGROUND_FILL
				style.background_stroke_color = FIRE_BACKGROUND_STROKE
				style.background_modulate = FIRE_BACKGROUND_FILL
			GlobalData.Element.EARTH:
				style.background_fill_color = EARTH_BACKGROUND_FILL
				style.background_stroke_color = EARTH_BACKGROUND_STROKE
				style.background_modulate = EARTH_BACKGROUND_FILL
			GlobalData.Element.LIGHT:
				style.background_fill_color = LIGHT_BACKGROUND_FILL
				style.background_stroke_color = LIGHT_BACKGROUND_STROKE
				style.background_modulate = LIGHT_BACKGROUND_FILL
			GlobalData.Element.DARK:
				style.background_fill_color = DARK_BACKGROUND_FILL
				style.background_stroke_color = DARK_BACKGROUND_STROKE
				style.background_modulate = DARK_BACKGROUND_FILL
	elif not move.is_magic and move.physical_type != GlobalData.PhysicalType.NONE:
		style.background_fill_color = PHYSICAL_BACKGROUND_FILL
		style.background_stroke_color = PHYSICAL_BACKGROUND_STROKE
		style.background_modulate = PHYSICAL_BACKGROUND_FILL
	style.use_background = move.get_move_template() != BattleMove.MoveTemplate.UTILITY
	return style

static func _resolve_move_icon_texture(move: BattleMove) -> Texture2D:
	if move.icon != null:
		return move.icon

	for candidate in move.get_icon_candidates():
		var resolved_from_key: Texture2D = _resolve_texture_from_key(StringName(candidate))
		if resolved_from_key != null:
			return resolved_from_key

	if move.is_magic and move.element != GlobalData.Element.NEUTRAL:
		match move.element:
			GlobalData.Element.FIRE:
				return FIRE_ICON_TEXTURE
			GlobalData.Element.EARTH:
				return EARTH_ICON_TEXTURE
			GlobalData.Element.LIGHT:
				return LIGHT_ICON_TEXTURE
			GlobalData.Element.DARK:
				return DARK_ICON_TEXTURE

	if not move.is_magic and move.physical_type != GlobalData.PhysicalType.NONE:
		return PHYSICAL_ICON_TEXTURE

	match move.get_move_template():
		BattleMove.MoveTemplate.HEAL, BattleMove.MoveTemplate.SUPPORT:
			return LIGHT_ICON_TEXTURE
		BattleMove.MoveTemplate.STATUS:
			return DARK_ICON_TEXTURE
		BattleMove.MoveTemplate.UTILITY:
			return EARTH_ICON_TEXTURE
		_:
			return PHYSICAL_ICON_TEXTURE

static func _resolve_texture_from_key(icon_key: StringName) -> Texture2D:
	match icon_key:
		&"custom_texture":
			return null
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
			return PHYSICAL_ICON_TEXTURE
		&"template_heal_template", &"move_heal":
			return LIGHT_ICON_TEXTURE
		&"template_status_template", &"move_status":
			return DARK_ICON_TEXTURE
		&"template_support_template", &"move_support":
			return LIGHT_ICON_TEXTURE
		&"template_utility_template", &"move_utility":
			return EARTH_ICON_TEXTURE
		&"target_aoe":
			return LIGHT_ICON_TEXTURE
		&"target_self":
			return EARTH_ICON_TEXTURE
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