1. **Time/Date Log:** [Fill in the date/time here]

2. **Current Focus Area:** Revamping the combat build system so players choose a 5-move loadout before battle, while keeping the combat gym useful for quick balance testing.

3. **What We Just Built:**
- Added move-level stat modifier fields to `Resources/Move.gd` so a move can contribute flat and percent bonuses while equipped.
- Added `equipped_moves` support to `Scenes/battler/battler.gd` with a safe setter that clamps the active loadout to 5 moves.
- Updated `Scripts/Battler/stats_manager.gd` so equipped move bonuses affect active strength, magic, defense, luck, speed, crit chance, crit damage, and max HP.
- Updated `Scripts/test_combat_gym.gd` so battlers temporarily randomize their equipped moves each turn for testing the new build system.
- Fixed the combat gym runtime error caused by assigning an `Array` directly to `equipped_moves` by switching to the Battler setter.
- Prepared `Scenes/UI/damage_value_popups.tscn` and attached `Scripts/UI/damage_value_popups.gd` so the damage popup can receive damage value, target HP, down meter, and weak/critical state later.
- Added example stat bonuses to a few move resources in `Resources/Moves/` to test the new system quickly.
- Ran syntax/error checks on the touched files and cleared the recent battle gym / popup script errors.

4. **Current State of Architecture:**
- `battler.gd` now owns the equipped-move loadout and exposes a setter for clamped 5-slot assignment.
- `stats_manager.gd` now combines base stats, equipment, status multipliers, and equipped-move modifiers in its active stat getters.
- `Scripts/test_combat_gym.gd` is still the temporary test harness and currently randomizes each battler's equipped moves every turn.
- `Scenes/UI/damage_value_popups.tscn` exists as a dedicated popup layout with separate nodes for damage value, health bar, down meter, and weak/critical labels so each piece can be animated independently later.

5. **Next Immediate Step:** Build the actual pre-battle move loadout UI in `SkillMenu` so the player can choose and swap their 5 moves intentionally instead of relying on the temporary randomizer in the combat gym. and there is still error with the E 0:00:00:731   _randomize_equipped_moves: Invalid type in function 'set_equipped_moves' in base 'CharacterBody2D (Battler)'. The array of argument 1 (Array) does not have the same element type as the expected typed array argument.
  <GDScript Source>test_combat_gym.gd:366 @ _randomize_equipped_moves()
  <Stack Trace> test_combat_gym.gd:366 @ _randomize_equipped_moves()
                test_combat_gym.gd:340 @ _on_turn_started()
                battlemanager.gd:309 @ start_next_turn()
                test_combat_gym.gd:296 @ _advance_turn_flow()
                test_combat_gym.gd:291 @ _begin_flow()
                test_combat_gym.gd:63 @ _ready()
from the looks of it, it has something to do with the skill list and equipped Moves

6. **Open Questions:**
- Should move bonuses stack additively, multiplicatively, or with a hybrid rule for specific stats?
- Should the pre-battle loadout be edited in the gym only, or also stored as a persistent player preset/resource?
- Should the damage popup animate as one grouped card or as separate layered elements for value, bars, and hit-type text?
- Should the temporary combat gym move randomizer stay available as a debug toggle after the real equip UI exists?

7. **Additional Notes:**
- The combat gym randomizer is temporary and only exists to test the build concept quickly.
- The damage popup scene already has the layout needed for future animation work, but it is not yet wired into combat damage events.
- Existing reaction and turn-order systems are still intact; the new build work was added on top of the current combat engine rather than replacing it.
