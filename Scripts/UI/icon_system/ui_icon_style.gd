extends Resource
class_name UIIconStyle

@export_group("Identity")
@export var key: StringName = &""

@export_group("Textures")
@export var icon_texture: Texture2D = null
@export var background_fill_texture: Texture2D = null
@export var background_stroke_texture: Texture2D = null

@export_group("Visibility")
@export var use_background: bool = true
@export var use_icon: bool = true

@export_group("Tint")
@export var icon_modulate: Color = Color(1, 1, 1, 1)
@export var background_modulate: Color = Color(1, 1, 1, 1)

@export_group("Palette")
@export var background_fill_color: Color = Color(1, 1, 1, 1)
@export var background_stroke_color: Color = Color(0, 0, 0, 1)
@export var icon_fill_color: Color = Color(1, 1, 1, 1)
@export var icon_stroke_color: Color = Color(0, 0, 0, 1)

@export_group("Fallback")
@export var theme_icon_name: StringName = &""
@export var theme_icon_type: StringName = &"EditorIcons"

func has_background() -> bool:
	return use_background and (background_fill_texture != null or background_stroke_texture != null)

func has_icon() -> bool:
	return use_icon and (icon_texture != null or theme_icon_name != &"")