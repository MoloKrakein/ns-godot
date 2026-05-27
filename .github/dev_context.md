1. **Time/Date Log:** [Fill in on next machine: __________]

2. **Current Focus Area:** Stabilizing and expanding the combat loop in the test arena, especially turn order fairness, turn-order manipulation effects, and Down-state payoff flow.

3. **What We Just Built:**
- Wired the Party Panel UI to live battler data with a dedicated controller script (`Scripts/UI/party_panel.gd`) and attached it to `Scenes/UI/party_panel.tscn`.
- Integrated Party Panel into combat gym runtime (`Scripts/test_combat_gym.gd`) and later constrained panel usage to player side only.
- Fixed signal mismatch crash in combat gym by making `_refresh_combat_ui` accept optional signal payload.
- Fixed negative HP/state issues by clamping HP after damage and resetting down meter on battler initialization in `Scenes/battler/battler.gd`.
- Reworked turn flow from immediate re-queueing to round-based queue rebuild in `Scenes/battle manager/battlemanager.gd`:
	- First round: speed/static ordering.
	- Later rounds: rebuilt from stored Action Value.
- Added move-driven turn-order manipulation system:
	- New `BattleMove.TurnOrderManipulation` enum and exported fields in `Resources/Move.gd`.
	- BattleManager helpers for hasten, delay, place-before-actor, place-after-actor.
	- Applied manipulation during move effect resolution.
- Added broad test move loadout directly in `Scenes/combat_gym.tscn` for both player battlers:
	- All four elemental test attacks (Fire/Earth/Dark/Light).
	- Turn-order moves (`Tactical Relay`, `Quick Order`, `Order Jam`).
	- Buff moves (`Rally Strength`, `Quick Step`) with local status resources.
- Improved conductive/proxy spread consistency by deriving source primer from reaction config when available.
- Upgraded `Scenes/UI/skill_menu.tscn` to a scrollable move list:
	- Added `ScrollContainer` viewport.
	- Updated button path in both scene and `Scripts/UI/skill_menu.gd`.
	- Tuned size so list behavior supports large move sets.
- Added Down-state payoff mechanics in BattleManager:
	- Extra turn granted to attacker when a target is newly downed.
	- One-time all-out attack trigger when opposing party is fully down (high burst, defense/affinity bypass-style direct HP cut).
	- Removed duplicate turn-order manipulation call in move effect flow.

4. **Current State of Architecture:**
- `battler.gd`:
	- HP is now clamped after direct damage application.
	- Down meter is reset during `_ready()` initialization.
	- Existing weakness/crit/down/adrenaline interaction still present.
- `stats_manager.gd`:
	- No structural rewrite today; still central for computed active stats and equipment + status multipliers.
- UI:
	- `party_panel.tscn` is script-driven and bound to battler snapshots/signals.
	- Combat gym uses player-only Party Panel currently.
	- `skill_menu.tscn` button area is now scrollable for long skill lists.

5. **Next Immediate Step:**
Run a focused in-editor combat verification pass in `combat_gym.tscn` for three scenarios: (a) extra-turn-on-down consistency, (b) full-party-down all-out trigger timing and damage feel, (c) turn-order manipulation outcomes across current round and next rebuilt round.

6. **Open Questions:**
- Should extra turn on Down be unlimited, once-per-action, or gated behind weakness/crit conditions?
- Should all-out attack execute as a cinematic move resource instead of direct HP deduction?
- Should all-out trigger only when targets are downed-but-alive, or also when they are simply at 0 HP?
- Should turn-order manipulation values be additive to AV, multiplicative, or capped per round?
- Should status effects (not only moves) also be allowed to manipulate turn order in data-driven form?
- Should enemy side also get dedicated Party Panel visuals later, or stay text-only in gym?

7. **Additional Notes:**
- Existing reaction resources are somewhat mixed (some chain definitions use legacy fields and not all entries are normalized); test coverage should continue using controlled local move resources in combat gym.
- There is now a repository memory note indicating the queue moved to round-based behavior after first speed-sorted queue.
- Current session ended at a good checkpoint: code compiles cleanly after each major patch and no outstanding syntax errors were reported in modified files.
1. **Time/Date Log:** [Fill in the date/time here]
2. **Current Focus Area:** Building and polishing the combat UI prototype, especially the skill menu, target selection flow, and move icon presentation.
3. **What We Just Built:**
- Updated `Scripts/UI/icon_system/ui_icon_library.gd` to support the new support icon family: `Heal`, `Buff`, and `Debuff`, plus their multi-target versions `M_Heal`, `M_Buff`, and `M_Debuff`.
- Added multi-target background color swapping in the icon library, including the fire multi-target special fill color `#FF2626`.
- Adjusted `Resources/Move.gd` so placeholder icon names now align with the new support icon naming.
- Cleaned up `Scenes/UI/skill_menu.tscn` and attached `Scripts/UI/skill_menu.gd` so the move list prototype is now built dynamically from battler moves.
- Wired `Scenes/combat_gym.tscn` and `Scripts/test_combat_gym.gd` to use the skill menu prototype, with a separate target button container so the move list and target list do not overlap.
- Fixed the move button prefab in `Scenes/UI/buttons/movebutton/button.tscn` so hover and click coverage now matches the visible button instead of being interrupted by child controls.
- Updated the combat gym flow so multi-target moves still ask the player to pick a target first, instead of executing immediately.
4. **Current State of Architecture:**
- `battler.gd` and `stats_manager.gd` were not changed in this session.
- The UI now has a clearer split between the move list prototype, the move button prefab, and the target-selection panel.
- `Scripts/UI/icon_system/ui_icon_library.gd` remains the central place for icon texture and background resolution.
- `Resources/Move.gd` still provides the data hooks that let designers override icons when a move needs custom art.
- The combat prototype logic in `Scripts/test_combat_gym.gd` now matches the battle manager's targeting model by routing multi-target moves through a chosen primary target first.
5. **Next Immediate Step:** Boot the project on the other PC and test the combat gym flow end to end, focusing on the new target-selection UX for multi-target moves and making sure the move list still lays out correctly.
6. **Open Questions:**
- Should the target buttons get a clearer label or styling so it is obvious they are selecting the primary target for an AoE move?
- Do any remaining move resources need explicit `icon` or `ui_icon_name` overrides now that the support icon family is wired in?
- Is the current staircase spacing in `Scenes/UI/skill_menu.tscn` good enough for real content, or should it become more data-driven later?
7. **Additional Notes:**
- The battle manager already supports resolving AoE from a selected primary target, so the UX change only needed to happen in the UI flow.
- The recent hover issue was caused by mouse handling on child controls inside the button prefab, not the button logic itself.
- The combat gym layout issue was a scene spacing problem, not a bug in the skill menu script.