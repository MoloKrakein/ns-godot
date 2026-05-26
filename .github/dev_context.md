1. **Time/Date Log:** [Fill in the date/time here]
2. **Current Focus Area:** UI move icon resolution for single-target vs multi-target spell art.
3. **What We Just Built:**
- Updated `Scripts/UI/icon_system/ui_icon_library.gd` so move icons now resolve by default from the move's target type.
- Single-target moves use the normal `Arts/UI/Icons/Icons/` art.
- Multi-target moves use the new `Arts/UI/Icons/Multi_icons/` art.
- Kept explicit move overrides intact: a move's direct `icon` texture or `ui_icon_name` still wins over the default resolver.
- Added support for the new `M_Fire`, `M_Earth`, `M_Light`, `M_Darkness`, and `M_Physical` assets.
4. **Current State of Architecture:**
- `battler.gd` and `stats_manager.gd` were not changed in this session.
- The UI icon system is centralized in `Scripts/UI/icon_system/ui_icon_library.gd`.
- `Move.gd` already exposes `icon` and `ui_icon_name`, so designers can override the auto-picked icon from the resource itself.
5. **Next Immediate Step:** Audit the move resources in `Resources/Moves/` and set `ui_icon_name` or `icon` only where a move needs custom art instead of the default target-based icon.
6. **Open Questions:**
- Are there any moves that should intentionally ignore target-based art and always use a custom icon?
- Do any future move types need their own separate icon family beyond single-target and multi-target?
7. **Additional Notes:**
- The icon backgrounds were already working correctly before the icon-body fix.
- The main bug was fallback precedence, not the background palette logic.
- The current resolver now has a clear precedence order: direct texture override, named override, then automatic target-based default.