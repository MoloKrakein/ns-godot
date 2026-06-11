extends Control
class_name SkillMenu

signal move_selected(move: BattleMove)

@export var move_button_scene: PackedScene = preload("res://Scenes/UI/buttons/movebutton/button.tscn")
@export var button_group_path: NodePath = NodePath("MenuRoot/Bg/Buttons/ButtonGroup")
@export var include_basic_attack: bool = true
@export var left_staircase_margins: PackedFloat32Array = PackedFloat32Array([0.0, 12.0, 24.0, 36.0, 48.0])
@export var overflow_margin_step: float = 12.0
@export var auto_rebuild_on_ready: bool = false
@export var preview_moves: Array[BattleMove] = []

var _bound_moves: Array[BattleMove] = []

@onready var _button_group: VBoxContainer = get_node_or_null(button_group_path) as VBoxContainer
@onready var _equip_slot_group: HBoxContainer = get_node_or_null("MenuRoot/Bg/EquipDisplay/SlotGroup") as HBoxContainer

func _ready() -> void:
    if _button_group == null:
        push_error("SkillMenu is missing a valid button_group_path.")
        return

    if auto_rebuild_on_ready and not preview_moves.is_empty():
        set_moves(preview_moves)

func populate_for_battler(battler: Battler) -> void:
    var moves: Array[BattleMove] = []
    if battler == null:
        set_moves(moves)
        return

    # Show only the equipped moves (the moves the battler will actually use).
    # If no equipped moves are assigned, fall back to showing the full learned pool
    # so the designer can equip moves manually.
    var equipped: Array[BattleMove] = battler.get_equipped_moves()
    if equipped != null and equipped.size() > 0:
        # Use equipped order as the actionable move list
        for m in equipped:
            if m != null:
                moves.append(m)
    else:
        # Fallback: show basic attack + learned skills so the player/ designer can equip
        if include_basic_attack and battler.basic_atk != null:
            moves.append(battler.basic_atk)
        for skill: BattleMove in battler.skills_list:
            if skill != null:
                moves.append(skill)

    set_moves(moves)
    # Update equipped slots display
    if _equip_slot_group != null:
        set_equipped_slots(battler.get_equipped_moves())

func set_equipped_slots(equipped: Array[BattleMove]) -> void:
    if _equip_slot_group == null:
        return
    for i in range(_equip_slot_group.get_child_count()):
        var child = _equip_slot_group.get_child(i)
        if child is Label:
            var lbl: Label = child as Label
            if i < equipped.size() and equipped[i] != null:
                lbl.text = equipped[i].move_name
            else:
                lbl.text = "Empty"

func set_moves(moves: Array[BattleMove]) -> void:
    _bound_moves.clear()
    _bound_moves.append_array(moves)
    _rebuild_buttons()

func clear_moves() -> void:
    _bound_moves.clear()
    _clear_button_rows()

func _rebuild_buttons() -> void:
    if _button_group == null:
        return
    if move_button_scene == null:
        push_error("SkillMenu move_button_scene is not assigned.")
        return

    _clear_button_rows()

    for index: int in range(_bound_moves.size()):
        var move: BattleMove = _bound_moves[index]
        if move == null:
            continue

        var row: HBoxContainer = HBoxContainer.new()
        row.name = "Row%d" % (index + 1)
        _button_group.add_child(row)

        var spacer: Container = Container.new()
        spacer.name = "LeftSpacer"
        spacer.custom_minimum_size = Vector2(_get_margin_for_row(index), 0.0)
        row.add_child(spacer)

        var button_node: Node = move_button_scene.instantiate()
        row.add_child(button_node)

        if button_node is MoveButton:
            var move_button: MoveButton = button_node as MoveButton
            move_button.setup_move(move)
            move_button.pressed.connect(_on_move_pressed.bind(move))

func _clear_button_rows() -> void:
    if _button_group == null:
        return
    for child: Node in _button_group.get_children():
        child.queue_free()

func _get_margin_for_row(index: int) -> float:
    if left_staircase_margins.is_empty():
        return 0.0
    if index < left_staircase_margins.size():
        return left_staircase_margins[index]

    var last_index: int = left_staircase_margins.size() - 1
    var overflow_rows: int = index - last_index
    return left_staircase_margins[last_index] + (overflow_margin_step * float(overflow_rows))

func _on_move_pressed(move: BattleMove) -> void:
    move_selected.emit(move)
