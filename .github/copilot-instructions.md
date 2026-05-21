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

## 11. About the Game Mechanics and Design (For Context)
- The game is a turn-based RPG with a focus on elemental combat and strategic status effects.
- Characters can be in different "Posture" states (like Normal, Guarded, or Down) that affect their vulnerability and the effectiveness of certain actions.
- The "Down State" is a central mechanic where when the `down_meter_fill` is full, the character enters a Down State for one turn,the character will skip their next turn and then reset the `down_meter_fill` to 0. During the Down State, the character is more vulnerable to certain types of attacks and may have different interactions with status effects and reactions.
- When all characters on one side are in the Down State, the opposing will be entered into a "Overdrive", which gonna make the opposing side's attacks more powerful for a limited number of turns, and the player can use this to turn the tide of battle if used strategically, and also the normal elemental reactions will be upgraded and merged to "Overdrive Reactions" / "Ascended Reactions" with more powerful effects. and the player can also use this to turn the tide of battle if used strategically.
- The Commander's primary attack uses the Resonance Pistol, which initiates a rhythm-based targeting mini-game. Upon firing, shrinking UI rings appear on the aiming reticle, requiring the player to click in a precise 1-2-3 sequence perfectly on beat. Hitting these timings perfectly guarantees the application of an Elemental Primer to the target(s) and triggers an "Auto-Reload" status, granting a free, automatic reload for the next turn. Failing the rhythm sequence misses the primer application and forces the Commander to waste a future turn manually reloading. During this rhythm sequence, the player's crosshair movement dictates the type of party follow-up attack. If the player utilizes a "Spread Pattern" by successfully landing rhythmic shots across multiple different enemies, it triggers a "Mini All-Out Attack," where AI companions dash in to deal moderate AoE Posture (Down Bar) damage to the entire enemy field. Conversely, if the player uses a "Focus Pattern" by landing every rhythmic shot perfectly
- The Adrenaline mechanic is a risk-reward state machine triggered whenever a character hits an enemy's weakness. This immediately places the character into the "Adrenaline State," which buffs their dodge/evasion chance and forces the enemy to target them. When the enemy attacks, the outcome dictates the flow: if the attack hits, the character loses the Adrenaline state and its buffs; if the character successfully dodges, they retain the status. On that character's subsequent turn, the player is prompted to choose between two actions: "Cash Out" or "Double Down." Choosing to "Cash Out" safely consumes the Adrenaline status to instantly deal damage, restore MP, and fill the enemy's `down_meter_fill`. Choosing to "Double Down" initiates a gamble: it intentionally decreases the character's dodge/evasion chance in exchange for multiplying their damage output on a future turn. However, if the character gets hit by an enemy while in this Double Down stance, they lose their accumulated stacks and the gamble fails entirely.
- Elemental combat revolves around the Primer and Trigger system, where characters can be primed with an element and then triggered with a reacting element to cause powerful Chain Reactions. Managing these reactions and the resulting status effects is key to mastering the combat system.
- This game is designed the player is an "commander" directing a AI-controlled squad of characters, rather than directly controlling the characters themselves. This means that player only issue commands and advise the AI on the player turns, and the AI will execute those commands to the best of its ability, and also the player can use the "Tactics" system to set up conditional commands (e.g., "If an ally is below 50% HP, use a healing item on them") to add another layer of strategic depth to the combat. The player only control the AI when there is opportunity / critical moments like the "Adrenaline State" or "Overdrive"
- This game is heavily inspired by other turn-based RPGs with elemental combat and strategic status effects, such as the "Shin Megami Tensei" series, "Persona" series, and "Genshin Impact". The combat system is designed to encourage players to think strategically about elemental interactions, status effects, and the timing of their actions to overcome challenging battles.

<!-- ## 5. 3D & UI Integration (HD-2D Style)
- Characters are 2D Sprites rendered in a 3D environment (using `Sprite3D` or `MeshInstance3D` with Y-Billboard).
- Menus (like the player's phone app UI) are built using standard 2D Control nodes but are projected onto 3D meshes using `SubViewport` and `ViewportTexture`. When writing UI scripts, target the `SubViewport` nodes. -->