1. **Time/Date Log:** (____________________)

2. **Current Focus Area:** Damage UI decoupling and post-calculation events (ensuring UI only reacts to finalized damage results and not internal combat logic).

3. **What We Just Built:**
- Added a post-calculation `damage_resolved` signal to `Scenes/battler/battler.gd` and emitted it after damage math (and on blocked hits).
- Centralized HP/MP mutation APIs on `Battler`: `set_current_hp`, `take_hp_damage`, `set_current_mp`, `spend_mp`, and related emitters (`health_changed`, `mana_changed`, `ui_state_changed`).
- Updated `Scenes/battle manager/battlemanager.gd` to use `spend_mp` and to emit `damage_resolved` for AoE/all-out attacks instead of directly emitting older signals.
- Wired `Scripts/test_combat_gym.gd` to listen to `damage_resolved` and spawn `DamageValuePopups` instances; popup positioning now prefers the attacker's party node, then a `Popup Pos` test node, then the target battler's world position.
- Extended `Scripts/UI/damage_value_popups.gd` to accept `is_resist` and `is_block` flags and show corresponding visuals.
- Implemented the Affinity diamond UI (`Scenes/UI/affinity_panels.tscn` + `Scripts/UI/affinity_panels.gd`) and consolidated physical affinity (collapsed multiple physical types into a single `physical_affinity` in `Resources/Stats.gd`).
- Fixed move enum/indexing issues and showed correct type icons for Support moves in `Scripts/UI/buttons/movebutton/move_button.gd`.
- Implemented a static 5-slot `SkillMenu` UI and removed ScrollContainer; added `PartyPanel` inspector toggle to show `ActiveStats` for debugging.

4. **Current State of Architecture:**
- `battler.gd`: now exposes `damage_resolved` (post-calculation UI event) and central mutation helpers. Elemental primer + reaction system remains in `battler.gd` (priming, triggering, reaction cooldowns), but UI now subscribes to `damage_resolved` instead of raw combat internals.
- `Stats.gd` / resources: physical affinity consolidated to one `physical_affinity` value and `get_physical_affinity_map()` abstracts mapping; existing `.tres` resources may still serialize old numeric enum values (migration advised).
- UI: `DamageValuePopups` updated to support resist/block; `test_combat_gym` is the temporary harness for spawning popups and verifying flow; affinity panels and party/skill UIs have been updated as described.

5. **Next Immediate Step:**
- Run or create a migration script to update existing `.tres` resources to the new `PhysicalType` enum (map any non-NONE values to `PHYSICAL`) — this avoids silent affinity mismatches.
- After migration: implement equip/unequip persistence and drag/drop swap for `SkillMenu` (store presets or write to player save resource).

6. **Open Questions:**
- Do you prefer per-battler popup anchors (each battler's UI node) or party-level anchors (current implementation)?
- Should `damage_resolved` include additional context (e.g., attack source id, move id, hit location) for richer UI behavior?
- Do you want me to create and run the automatic `.tres` migration now or leave it for manual review?

7. **Additional Notes:**
- File paths edited recently: `Scenes/battler/battler.gd`, `Scenes/battle manager/battlemanager.gd`, `Scripts/test_combat_gym.gd`, `Scripts/UI/damage_value_popups.gd`, `Resources/Stats.gd`, `Scenes/UI/affinity_panels.tscn`, `Scripts/UI/affinity_panels.gd`, `Scripts/UI/buttons/movebutton/move_button.gd`, and `Scenes/UI/skill_menu.tscn`.
- To verify on another machine: open the project, load `Scenes/combat_gym.tscn`, ensure `DamagePopupLayer` and `Popup Pos` nodes are assigned in the inspector, then run and trigger damage to see popups.
- Pending work: resource migration, SkillMenu equip persistence, drag/drop, tests, and docs.
