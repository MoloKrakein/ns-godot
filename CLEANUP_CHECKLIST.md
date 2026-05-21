# Template Cleanup Checklist

This document lists all project-specific content that should be removed to clean the template for reuse.

## ✓ Files & Folders to DELETE

### Artwork & Models (Project-Specific)
- [ ] `Art/` - All artwork is specific to this project
- [ ] `Models/` - All 3D models are specific to this project

### Development Logs
- [ ] `Exported_Code_Logs/` - Development artifacts not needed for template

### Translation Files (Project-Specific)
- [ ] `Chain Reaction.Duration.translation`
- [ ] `Chain Reaction.Effect.translation`
- [ ] `Chain Reaction.Element 2.translation`
- [ ] `Chain Reaction.Reaction.translation`
- [ ] `Chain Reaction.Role.translation`
- [ ] `Chain Reaction.csv`
- [ ] `Chain Reaction.csv.import`

### Test Scenes
- [ ] `Scenes/Battle_Arena3D_Test.tscn`
- [ ] `Scenes/Battle_Arena3D_Test.tscn.import`

### Test/Demo UI
- [ ] `Scenes/UI/radial_menu.tscn` (if any)

### Test Scripts
- [ ] `Scripts/phone_ui_test.gd`
- [ ] `Scripts/phone_ui_test.gd.uid`
- [ ] `Scripts/test_combat_gym.gd`
- [ ] `Scripts/test_combat_gym.gd.uid`
- [ ] `Scripts/radial_menu_Test.gd`
- [ ] `Scripts/radial_menu_Test.gd.uid`

---

## ✓ Folders to EMPTY (Keep Structure)

### Resources to Clear
- [ ] `Resources/Party/` - Remove all character templates, keep folder
- [ ] `Resources/Moves/` - Remove all move templates, keep folder  
- [ ] `Resources/Equipment/` - Remove all equipment templates, keep folder

**Action:** Delete contents but recreate `.gitkeep` files to keep folders tracked

---

## ✓ Files to KEEP (Core Engine)

### Battle System
- [x] `Scripts/global_data.gd` - Core configuration
- [x] `Scripts/item_database.gd` - Item system
- [x] `Scripts/Battler/` - All battler components
- [x] `Scripts/battle manager/` - Battle orchestration

### Resources Base Classes
- [x] `Resources/Stats.gd`
- [x] `Resources/Move.gd`
- [x] `Resources/Equipment.gd`
- [x] `Resources/Consumable.gd`
- [x] `Resources/StatusEffect.gd`
- [x] `Resources/chain_reaction_importer.gd`
- [x] `Resources/ElementAffinityEntry.gd`
- [x] `Resources/PhysicalAffinityEntry.gd`

### Reactions (Keep All)
- [x] `Resources/Reactions/chain_*.tres` - All chain reaction definitions

### Status Effects Base
- [x] `Resources/Status Effects/` - Keep structure

### Scenes - Base Templates
- [x] `Scenes/battler/battler.tscn` - Battler prefab
- [x] `Scenes/battler/battler.gd` - Battler script
- [x] `Scenes/battle manager/battle_arena.tscn` - Base battle scene
- [x] `Scenes/battle manager/battlemanager.gd` - Battle manager script

### Project Files
- [x] `project.godot` - Keep (it's the project config)
- [x] `.gitignore`, `.gitattributes`, `.git` - Keep

### Addons
- [x] `addons/` - Keep all (they're engine-agnostic tools)

---

## ✓ Special Cases

### UI Scenes
The `Scenes/UI/` folder should be reviewed:
- Keep: `battle_hud_manager.tscn` if it's a generic battle UI system
- Keep: `battler_hud_panel.tscn` if it's a generic battler display
- Delete: Game-specific UI implementations (phone menu, etc.)

**Recommendation:** Review each UI scene and keep only generic HUD components

### Cleanup Script
- [ ] Delete `cleanup_template.py` after running

---

## Manual Cleanup Instructions

If you can't use the automated script, follow these steps:

### On Windows (File Explorer)
1. Open project folder
2. Delete each folder/file listed in "DELETE" section
3. For "EMPTY" folders:
   - Open folder
   - Select all contents (Ctrl+A)
   - Delete (Del)
   - Right-click → New File → Text Document
   - Name it `.gitkeep`
   - Save and close

### In Godot Editor
1. Open project in Godot
2. Go to FileSystem panel (left side)
3. Right-click each file/folder in "DELETE" section
4. Select "Delete" or "Delete File"
5. For "EMPTY" folders, use same process for contents

---

## Verification Checklist

After cleanup, verify:

- [ ] Project still opens in Godot without errors
- [ ] Battle scenes and scripts are intact
- [ ] `Global Data` and `Item Database` autoloads load correctly
- [ ] Resource base classes are all present
- [ ] `Scenes/battler/battler.tscn` can be instanced
- [ ] `Scenes/battle manager/battle_arena.tscn` loads
- [ ] `Resources/Party/`, `Resources/Moves/`, `Resources/Equipment/` folders exist (even if empty)

---

## Git Workflow

After cleanup:

```bash
# Stage all changes
git add -A

# Create commit
git commit -m "Create clean combat engine template

- Remove project-specific content (art, models, test scenes)
- Remove test scripts and translations
- Empty resource folders for new projects to fill
- Add comprehensive documentation (README, TEMPLATE_USAGE, ARCHITECTURE)
- Keep all core engine systems intact for reuse

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# Create branch (if not already created)
git checkout -b combat-engine-template

# Push to remote
git push origin combat-engine-template
```

---

**Status:** Ready for template creation! ✓
