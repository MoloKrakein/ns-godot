extends Node

# Element set simplified per user request
enum Element {NEUTRAL,FIRE,EARTH,DARK,LIGHT}
enum PhysicalType {PHYSICAL}

# No element advantage table — all element interactions are neutral by default.
var elements = { Element.NEUTRAL: {} }

func get_mult(attk_element: Element, deff_element: Element) -> float:
	return 1.0

func get_reaction_id(primer: Element, trigger: Element) -> String:
	return ItemDatabase.get_reaction_id(primer, trigger)