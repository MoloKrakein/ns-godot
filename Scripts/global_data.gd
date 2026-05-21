extends Node

# Element Diagram Reference : https://app.diagrams.net/#G1aOTtExOuKytT-BcfikGi5PLnJVyz7wpg#%7B%22pageId%22%3A%220KW8x6qtRERvc5qper4m%22%7D
enum Element {NEUTRAL,FIRE,WATER,ICE,GRASS,ELECTRO,NEON,RADIUM}
enum PhysicalType {NONE, SLASH, PIERCE, TRAUMA}
enum AscendedElement {NONE, THERMAL, ORGANIC, SYNTHETIC}

var elements = {
	# ATK Element | Value : {Defender Element : Multiplier}
	# "Fire": {"Grass":2.0, "Water": 0.5, "Fire": 0.25},
	# "Water": {"Fire":2.0, "Grass": 0.5, "Water": 0.25},
	# "Grass": {"Water":2.0, "Fire": 0.5, "Grass": 0.25},
	# "Electro": {"Water":2.0, "Grass": 1.0, "Electro": 0.25},
	# "Neutral":{}

	Element.FIRE: {Element.ICE:2.0, Element.GRASS:1.2, Element.ELECTRO:0.5, Element.WATER:0.5, Element.FIRE:0.2},
	Element.WATER: {Element.FIRE:2.0, Element.GRASS:1.2, Element.ELECTRO:0.5, Element.ICE:0.5, Element.WATER:0.2},
	Element.GRASS: {Element.ELECTRO:2.0, Element.ICE:1.2, Element.WATER:0.5, Element.FIRE:0.5, Element.GRASS:0.2},
	Element.ICE: {Element.WATER:2.0, Element.ELECTRO:1.2, Element.FIRE:0.5, Element.GRASS:0.5, Element.ICE: 0.2},
	Element.ELECTRO: {Element.WATER:2.0, Element.FIRE:1.2, Element.ICE:0.5, Element.GRASS:0.5, Element.ELECTRO: 0.2},
	Element.NEON : {Element.RADIUM:2.0, Element.NEON:0.1},
	Element.RADIUM: {Element.NEON:2.0, Element.RADIUM:0.1},
	Element.NEUTRAL:{}


}

func get_mult(attk_element: Element, deff_element: Element) -> float:
	if elements.has(attk_element):
		return elements[attk_element].get(deff_element,1.0)

	return 1.0

func get_reaction_id(primer: Element, trigger: Element) -> String:
	return ItemDatabase.get_reaction_id(primer, trigger)

func get_ascended_element(element: Element) -> AscendedElement:
	match element:
		Element.FIRE, Element.WATER, Element.ICE:
			return AscendedElement.THERMAL
		Element.ELECTRO, Element.GRASS:
			return AscendedElement.ORGANIC
		Element.NEON, Element.RADIUM:
			return AscendedElement.SYNTHETIC
		_:
			return AscendedElement.NONE