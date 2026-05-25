extends RefCounted
class_name UIIconLibrary

static func create_generic_style(key: StringName, icon_texture: Texture2D = null, background_texture: Texture2D = null, show_background: bool = true) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = key
	style.icon_texture = icon_texture
	style.background_texture = background_texture
	style.use_background = show_background
	return style

static func create_move_style(move: BattleMove) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = move.get_icon_key()
	style.icon_texture = move.icon
	style.use_background = move.get_move_template() != BattleMove.MoveTemplate.UTILITY
	style.theme_icon_name = move.get_placeholder_icon_name()
	return style

static func create_element_style(element: GlobalData.Element) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = StringName("element_%s" % GlobalData.Element.keys()[element].to_lower())
	style.use_background = element != GlobalData.Element.NEUTRAL
	return style

static func create_reaction_style(reaction_id: String) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = StringName(reaction_id)
	style.use_background = reaction_id != ""
	return style

static func create_status_style(status: StatusEffect) -> UIIconStyle:
	var style: UIIconStyle = UIIconStyle.new()
	style.key = StringName(status.id)
	style.use_background = true
	style.use_icon = true
	return style