1. **Time/Date Log:** [Fill in the date/time here]

2. **Current Focus Area:** Locking down the combat build/loadout flow so the UI shows the moves the battler actually uses, while the gym stays useful for fast balance checks.

3. **What We Just Built:**
- Added move-level stat modifier fields to `Resources/Move.gd` so equipped moves can contribute flat and percent bonuses.
- Added `equipped_moves` support to `Scenes/battler/battler.gd` with a safe setter that clamps the active loadout to 5 moves.
- Updated `Scripts/Battler/stats_manager.gd` so equipped move bonuses affect active strength, magic, defense, luck, speed, crit chance, crit damage, and max HP.
- Added a live debug readout to `Scripts/UI/party_panel.gd` and `Scenes/UI/party_panel.tscn` showing stat breakdowns as base, equipment, move, multiplier, and active value.
- Updated `Scripts/UI/skill_menu.gd` so the move list shows equipped moves as the primary actionable set, with a fallback to the learned pool when no loadout exists.
- Added a visible 5-slot equipped display to `Scenes/UI/skill_menu.tscn` so the current loadout can be seen beside the move list.
- Updated `Scripts/test_combat_gym.gd` so battlers can still randomize equipped moves for testing, but that randomizer is now gated by a toggle.
- Fixed the combat gym runtime error caused by assigning an untyped `Array` directly to `equipped_moves` by routing through `set_equipped_moves()`.
- Added consistent element-based test bonuses to the combat gym move templates in `Scenes/combat_gym.tscn` so fire, earth, dark, light, and utility moves are easier to verify.
- Ran syntax/error checks on the touched files and cleared the recent battle gym, skill menu, and HUD debug script errors.

4. **Current State of Architecture:**
- `battler.gd` owns the equipped-move loadout and exposes a setter for clamped 5-slot assignment.
- `stats_manager.gd` combines base stats, equipment, status multipliers, equipped-move modifiers, and now also provides a stat debug breakdown helper for the UI.
- `Scripts/UI/skill_menu.gd` is now the visible combat move UI, showing usable equipped moves first instead of the raw learned pool.
- `Scripts/UI/party_panel.gd` now exposes live debug values for active stats, including a source-based breakdown that makes move bonuses easy to verify.
- `Scripts/test_combat_gym.gd` remains the temporary test harness for randomized loadouts, but it is now optional rather than always on.
- `Scenes/combat_gym.tscn` contains the test move templates with explicit stat bonuses for loadout verification.

5. **Next Immediate Step:** Finish the actual pre-battle move loadout UI in `SkillMenu` so the player can intentionally assign and swap their 5 equipped moves instead of relying on the temporary gym randomizer.

6. **Open Questions:**
- Should move bonuses stack additively, multiplicatively, or with a hybrid rule for specific stats?
- Should the pre-battle loadout be edited in the gym only, or also stored as a persistent player preset/resource?
- Should the damage popup animate as one grouped card or as separate layered elements for value, bars, and hit-type text?
- Should the temporary combat gym move randomizer stay available as a debug toggle after the real equip UI exists?

7. **Additional Notes:**
- The combat gym randomizer is temporary and only exists to test the build concept quickly.
- The damage popup scene already has the layout needed for future animation work, but it is not yet wired into combat damage events.
- Existing reaction and turn-order systems are still intact; the new build work was added on top of the current combat engine rather than replacing it.
