extends Control
class_name MoveButton

signal pressed

@onready var button: Button = $Button
@onready var icon_slot: UIIconSlot = $UIIconSlot
@onready var move_name_label: Label = $Button/MarginContainer/HBoxContainer/MoveName
# @onready var cost_type_label: Label = $Button/MarginContainer/HBoxContainer/CostBox/CostType
@onready var cost_label: Label = $Button/MarginContainer/HBoxContainer/CostBox/CostLabel
@onready var magic_type_icon: TextureRect = $TypeBadge/MagicTypeIcon
@onready var physical_type_icon: TextureRect = $TypeBadge/PhysicalTypeIcon

func _ready() -> void:
    button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
    pressed.emit()

func setup_move(move: BattleMove) -> void:
    button.text = ""
    button.tooltip_text = "%s\n%s" % [move.get_button_label(), move.description]
    move_name_label.text = move.move_name
    move_name_label.clip_text = true
    move_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    # move_name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    # cost_type_label.visible = move.is_magic
    cost_label.text = str(move.mp_cost)
    # Show magic/type icon for moves that are magical or that consume MP (e.g., support moves using MP).
    var move_cat = move.get_move_category()
    magic_type_icon.visible = move.is_magic or (move.mp_cost > 0 and move_cat == move.MoveCategory.SUPPORT)
    # Show physical icon when the move is explicitly physical.
    physical_type_icon.visible = not move.is_magic and move.physical_type != GlobalData.PhysicalType.NONE
    icon_slot.set_style(UIIconLibrary.create_move_style(move))
