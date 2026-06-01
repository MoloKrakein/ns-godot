extends Node

# Element Diagram Reference : https://app.diagrams.net/#G1aOTtExOuKytT-BcfikGi5PLnJVyz7wpg#%7B%22pageId%22%3A%220KW8x6qtRERvc5qper4m%22%7D
enum Element {NEUTRAL,FIRE,EARTH,DARK,LIGHT}
# PhysicalType simplified to a single `PHYSICAL` type; specific physical subtypes
# (SLASH/PIERCE/TRAUMA) are folded into this single category to simplify UI.
enum PhysicalType {NONE, PHYSICAL}

# Minimal element interaction table for the 5-element system.
# Values are multipliers applied when attacker element hits defender element.
var elements = {
	Element.FIRE: {Element.EARTH:1.2, Element.DARK:1.0, Element.LIGHT:0.95, Element.FIRE:0.2},
	Element.EARTH: {Element.FIRE:0.9, Element.DARK:1.1, Element.LIGHT:1.2, Element.EARTH:0.2},
	Element.DARK: {Element.LIGHT:0.8, Element.EARTH:1.15, Element.FIRE:1.0, Element.DARK:0.2},
	Element.LIGHT: {Element.DARK:1.2, Element.EARTH:0.9, Element.FIRE:1.0, Element.LIGHT:0.2},
	Element.NEUTRAL: {}
}

func get_mult(attk_element: Element, deff_element: Element) -> float:
	if elements.has(attk_element):
		return elements[attk_element].get(deff_element,1.0)

	return 1.0

func get_reaction_id(primer: Element, trigger: Element) -> String:
	return ItemDatabase.get_reaction_id(primer, trigger)

