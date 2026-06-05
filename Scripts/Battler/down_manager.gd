extends Node
class_name DownManager

signal character_downed(battler)
signal character_recovered(battler)
signal down_meter_updated(current_down_meter, max_down_meter)

# @onready var battler = get_parent()
var battler: Battler

var current_meter: int = 0
var max_meter: int = 100
var is_downed: bool = false

func initialize(battler_node: Battler) -> void:
	battler = battler_node

func increase_meter(amount: int):
	if is_downed:
		return

	current_meter += amount
	if current_meter >= max_meter:
		current_meter = max_meter
		is_downed = true
		emit_signal("character_downed", battler)
	else:
		emit_signal("down_meter_updated", current_meter, max_meter)

func reset_meter():
	current_meter = 0
	is_downed = false
	emit_signal("down_meter_updated", current_meter, max_meter)
	emit_signal("character_recovered", battler)
