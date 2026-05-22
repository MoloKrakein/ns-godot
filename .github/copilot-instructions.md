---
name: create-instructions
description: 'Create an instructions file (.instructions.md) for a project rule or convention.'
argument-hint: What rule or convention to enforce?
disable-model-invocation: true
---
# Godot 4 Turn-Based RPG Coding Standards

## 1. Engine & Syntax Rules
- **Engine:** Godot 4.x using strictly GDScript. NEVER use Godot 3 syntax.
- **Exporting:** Always use `@export` (not `export`).
- **Typing:** Use strict static typing for all variables, arrays, and functions (e.g., `var max_health: int = 100`, `func take_damage(amount: int) -> void:`).
- **Naming:** `snake_case` for variables/functions, and `PascalCase` for classes and Nodes.
- **Paths:** NEVER use absolute OS paths (like `C:\`). Always use `res://` (e.g., `res://Resources/Reactions/`).

## 2. The Modular "Battler" Architecture
Do not write monolithic scripts. The combatants in this game use a strict component-based architecture:
- **`battler.gd` (The Body):** This is the root node of the character (`res://Scenes/battler/battler.tscn`). It holds the visual nodes (like `Sprite3D`) and routes signals. It DOES NOT calculate damage.
- **`stats_manager.gd` (The Brain):** Attached as a child node. It handles all mathematical calculations for stats. It reads Custom Resources, applies multipliers (like `get_stats_multiplier`), and calculates final output. 
- **`status_manager.gd` (The Immune System):** Attached as a child node. It handles the application, ticking, and removal of `StatusEffect` resources. When ticking, it passes the *status object itself*, not an array index.

## 3. Data & Resource Management
- **Custom Resources:** Core game data (Stats, Moves, Equipment) is strictly managed using Custom Resources (`.tres`).
- **JSON Imports:** Chain reactions and complex relationships are parsed from JSON files via `chain_reaction_importer.gd` (using Godot 4's `JSON.parse_string()`) and saved as `.tres` files. Copilot should utilize this pipeline if asked to generate new reaction data.

## 4. Turn & Combat Flow
- **`battle_manager.gd` (The Director):** Turns are strictly managed by the Battle Manager's queue system. 
- **Turn Passing:** Do NOT create `while` or `_process` loops to wait for turns. Use the built-in `start_next_turn()` to move the turn queue forward.
- **Action Economy:** Actions that hit weaknesses affect the `down_meter_fill`. Combat mechanics must account for Down States and Turn Advantage.

## 5. Code Style & Best Practices
- **Comments:** Use comments to explain the "why" behind complex logic, especially in damage calculations and status interactions.
- **Signal Usage:** Use signals for communication between nodes (e.g., when a status effect is applied or removed).
- **No Hardcoding:** Avoid hardcoding values in scripts. Use constants or Custom Resources for any values that might need to be tweaked (like damage multipliers, status durations, etc.).

## 6. Elemental Chain Reactions (Primer & Trigger System)
- **The Core Mechanic:** Elemental combat uses a strict "Primer" and "Trigger" state machine. If a target is `NEUTRAL`, an elemental attack assigns its element to the `elemental_primer` variable. If the target is already primed, hitting them with a reacting element triggers a Chain Reaction and consumes the primer.
- **Global Data Dictionary:** All valid combinations (e.g., Electro + Water = `chain_short_circuit`) are strictly defined in `REACTION_MAP` inside `global_data.gd`. DO NOT invent elemental combinations that are not in this dictionary.
- **Reaction Architecture:** Chain Reactions are actually just `StatusEffect` Custom Resources with the `is_chain_reaction` flag set to true. 
- **Status Manager Routing:** When a reaction triggers, it is applied to the `status_manager.gd` via the `active_reactions` variable (kept separate from normal `active_status` arrays). The Status Manager is responsible for ticking the reaction's damage and duration.
- **Intertwined Systems:** Chain reactions frequently manipulate other systems. When writing reaction logic, be aware that a reaction might adjust the `down_meter_fill` (Posture/Down system), trigger an AoE spread in `battle_manager.gd`, or apply status locks (like Stun or Brainwash).
- **Cooldowns:** To prevent infinite looping, triggered reactions are placed in a `reaction_cooldowns` dictionary inside `battler.gd`. Always check this dictionary before applying a reaction multiplier.
- **Proxy AoE & Chain Decay Mechanics:** Certain elemental reactions in the game utilize a "Proxy AoE" (Conductive) targeting system rather than standard proximity-based area-of-effect. Instead of hitting enemies within a physical radius, a Proxy AoE "jumps" between enemies who share a specific Elemental Primer. When a specific reaction is triggered on a primary target (for example, hitting a "Wet" enemy with Electro to cause a "Short Circuit"), the combat manager must iterate through all other active enemies on the field. If any other enemies possess the exact same matching primer (Water), the reaction's effects automatically link and apply to them as well. However, to maintain combat balance, this logic uses a "Chain Decay" modifier. The Primary Target receives 100% of the reaction's damage and status effect durations. The first linked proxy target (Jump 1) receives only 50% damage and 50% status duration. The second linked proxy target (Jump 2) receives 25% damage and 25% status duration. The system should apply this descending mathematical modifier sequentially based on the array iteration, generally capping out after the 2nd or 3rd jump to prevent infinite loops.

## 7. Status Effect Management
- **Status Objects:** When applying or ticking status effects, always pass the entire status object (not just an index) to the `status_manager.gd`. This allows for more flexible and powerful status interactions (like guaranteed crits or conditional triggers).
- **Guaranteed Crits:** If a status effect guarantees a crit, it should set a flag on the status object (e.g., `guarantees_next_crit = true`). The `guaranteed_crit()` function in `status_manager.gd` should check for this flag and remove the status if it provides a guaranteed crit.
- **Status Removal:** When a status effect expires or is removed, use a dedicated cleanup function (e.g., `remove_active_reaction()`) to handle any necessary cleanup logic, rather than directly removing it in the `guaranteed_crit()` function or similar. This ensures that all side effects are properly handled and prevents potential bugs from skipping important cleanup steps.

## 8. Equipment & Inventory
- **Equipment as Resources:** All equipment items are Custom Resources with defined properties (like `bonus_crit_rate` or `bonus_crit_dmg`). The `stats_manager.gd` should loop through equipped items to calculate total stat bonuses. there is no hardcoded equipment logic in the stats manager; it should be data-driven based on the properties defined in the equipment resources.

## 9. Future-Proofing & Scalability
- **Extensibility:** The architecture is designed to be extensible. When adding new mechanics (like new status effects, reactions, or equipment), follow the existing patterns and data-driven design principles to ensure that new features integrate smoothly without requiring major refactors.
- **Performance:** Be mindful of performance when writing code, especially in areas that might be called frequently (like status ticking or damage calculations). Avoid unnecessary loops or complex calculations that could be optimized.

## 10. Other Files & Systems
- **`global_data.gd`:** This is the central repository for all game data dictionaries (like `REACTION_MAP`). When adding new data, ensure it is properly defined here and that any scripts that rely on this data are updated to reference it correctly.
- **`chain_reaction_importer.gd`:** This script is responsible for parsing JSON files to create Chain Reaction resources. When adding new reactions, ensure that the JSON data is correctly formatted and that the importer script can handle the new data structure if necessary.
- **`Exported_Code_Logs`:** is a folder that contains all the current code logs that have been exported from the project. These logs are used to help the AI understand the current state of the project and to avoid suggesting code that has been deleted or significantly changed. When writing new code, be sure to check the most recent logs to ensure that your suggestions are in line with the current codebase and do not reintroduce old bugs or issues that have already been addressed.
- **`Old Code`** : is a folder that contains all the old code. this code is from unity and is not relevant to the current project. it is only kept for reference and should not be used as a basis for new code suggestions.
- **`The original code`** the current framework is based on the original code of other project i make in godot, but the code has been heavily modified and rewritten to fit the new architecture and design of this project. while some of the core ideas and mechanics are inspired by the original code, the actual implementation is different and should not be directly compared to the original code. the original repo : https://github.com/MoloKrakein/SImple_RPG

## 11. About the Game Mechanics and Design and remake (For Context)
- The original game is just turn based combat where the player fights with one enemy, the original gameplay is very simple, the player can attack, defend, cast a spell, or use an item. where each turn the player and enemy will change their weakness to a random element. and if the player hits the enemy weakness they will get extra moves / one more turn. the original game only have very simple elemental without any reactions. this remake will adapt the new combat system that i have been developing for a while, the combat system is based on the idea of "primers" and "triggers". the player and enemy can be primed with an element, and if they are hit with a reacting element they will trigger a chain reaction. the chain reactions will have different effects based on the elements involved, and they will also interact with the posture/down system that i have been developing. the game will also have a more complex status effect system, where status effects can interact with each other and with the chain reactions in interesting ways.
- This is a remake of the game that i developed in unity, the original game is just a prototype and the code is very messy and not well organized, this remake will be a complete rewrite of the game using godot 4 and gdscript, and it will follow the coding standards and architecture that i have outlined in this document. the goal of this remake is to create a more polished and well-designed version of the game, with more complex mechanics and better performance.