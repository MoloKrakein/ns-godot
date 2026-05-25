extends Control
class_name UIIconSlot

@export var show_background: bool = true
@export var show_icon: bool = true
@export var icon_style: UIIconStyle = null

@onready var background_fill_rect: TextureRect = $BackgroundFill
@onready var background_stroke_rect: TextureRect = $BackgroundStroke
@onready var icon_rect: TextureRect = $Icon

func _ready() -> void:
	refresh()

func set_style(style: UIIconStyle) -> void:
	icon_style = style
	refresh()

func refresh() -> void:
	if background_fill_rect == null or background_stroke_rect == null or icon_rect == null:
		return

	var style: UIIconStyle = icon_style
	if style == null:
		background_fill_rect.visible = false
		background_fill_rect.texture = null
		background_stroke_rect.visible = false
		background_stroke_rect.texture = null
		icon_rect.visible = false
		icon_rect.texture = null
		return

	background_fill_rect.visible = show_background and style.use_background and style.background_fill_texture != null
	background_fill_rect.texture = style.background_fill_texture if background_fill_rect.visible else null
	background_fill_rect.modulate = style.background_fill_color

	background_stroke_rect.visible = show_background and style.use_background and style.background_stroke_texture != null
	background_stroke_rect.texture = style.background_stroke_texture if background_stroke_rect.visible else null
	background_stroke_rect.modulate = style.background_stroke_color

	var resolved_icon: Texture2D = style.icon_texture
	if resolved_icon == null and style.theme_icon_name != &"":
		resolved_icon = get_theme_icon(style.theme_icon_name, style.theme_icon_type)

	icon_rect.visible = show_icon and style.use_icon and resolved_icon != null
	icon_rect.texture = resolved_icon if icon_rect.visible else null
	icon_rect.modulate = style.icon_modulate