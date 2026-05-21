# Combat Engine Template Setup

## What's Been Done

✓ **Documentation Created:**
- `README.md` - Overview and getting started guide
- `TEMPLATE_USAGE.md` - Step-by-step setup for new projects
- `ARCHITECTURE.md` - Technical deep-dive into engine design
- `CLEANUP_CHECKLIST.md` - What to delete for a clean template
- `cleanup_template.py` - Automated cleanup script (optional)

✓ **Core Engine Preserved:**
- All battle system scripts (`Battler/`, `battle manager/`)
- All resource base classes
- All chain reaction definitions
- Global data and configuration

## Next Steps

### Option 1: Manual Cleanup (Safe & Simple)

1. Use the `CLEANUP_CHECKLIST.md` as your guide
2. Delete items listed in the "DELETE" section:
   - `Art/` folder
   - `Models/` folder
   - `Exported_Code_Logs/` folder
   - Test scene files
   - Test script files
   - Translation files

3. Empty these folders (keep structure):
   - `Resources/Party/`
   - `Resources/Moves/`
   - `Resources/Equipment/`

4. Create `.gitkeep` files in empty folders to preserve them in git

### Option 2: Automated Cleanup (Recommended)

Run the included Python script:

```bash
cd d:\Project\Godot\2d-turn-based-test.worktrees\agents-combat-engine-template-branch
python cleanup_template.py
```

This will:
- Delete all project-specific content
- Empty resource folders
- Keep folder structure intact

## After Cleanup

1. **Commit the clean template:**
   ```bash
   git add -A
   git commit -m "Create clean combat engine template

   - Remove project-specific content (art, models, test scenes)
   - Remove test scripts and translations
   - Add comprehensive documentation
   - Keep all core engine systems intact

   Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
   ```

2. **Create the template branch (if not already done):**
   ```bash
   git checkout -b combat-engine-template
   git push origin combat-engine-template
   ```

3. **Use for new projects:**
   - Clone/fork this branch to start a new project
   - Fill in `Resources/Party/`, `Resources/Moves/`, `Resources/Equipment/`
   - Follow `TEMPLATE_USAGE.md` to build your game

## File Structure After Cleanup

```
combat-engine-template/
├── README.md                    # Overview
├── TEMPLATE_USAGE.md           # Setup guide
├── ARCHITECTURE.md             # Technical docs
├── CLEANUP_CHECKLIST.md        # What was deleted
├── cleanup_template.py         # Cleanup script
│
├── project.godot               # Godot config
│
├── Scripts/
│   ├── global_data.gd          # Core constants & reactions
│   ├── item_database.gd        # Equipment database
│   ├── Battler/                # Character components
│   │   ├── battler.gd
│   │   ├── stats_manager.gd
│   │   ├── status_manager.gd
│   │   ├── down_manager.gd
│   │   └── affinity_manager.gd
│   └── battle manager/
│       ├── battlemanager.gd
│
├── Resources/
│   ├── Stats.gd                # Resource classes
│   ├── Move.gd
│   ├── Equipment.gd
│   ├── StatusEffect.gd
│   ├── Reactions/              # Chain reactions
│   │   └── chain_*.tres
│   ├── Status Effects/
│   ├── Party/ (.gitkeep)       # Empty - for new projects
│   ├── Moves/ (.gitkeep)       # Empty - for new projects
│   └── Equipment/ (.gitkeep)   # Empty - for new projects
│
├── Scenes/
│   ├── battler/
│   │   ├── battler.tscn        # Character prefab
│   │   └── battler.gd
│   └── battle manager/
│       ├── battle_arena.tscn   # Base battle scene
│       └── battlemanager.gd
│
├── addons/                     # Third-party plugins
│   ├── AsepriteWizard/
│   ├── jigglebones/
│   └── yard/
│
└── .git/                       # Git repository
```

## Documentation for New Projects

When using this template, users should:

1. **Read `README.md`** for overview
2. **Follow `TEMPLATE_USAGE.md`** for setup
3. **Reference `ARCHITECTURE.md`** for customization

## Questions?

Refer to the comprehensive documentation:
- **How do I start?** → `README.md` + `TEMPLATE_USAGE.md`
- **How does the engine work?** → `ARCHITECTURE.md`
- **What was deleted?** → `CLEANUP_CHECKLIST.md`
- **How do I customize combat?** → `ARCHITECTURE.md` extensibility section

---

**Template Status:** Ready to deploy! 🚀
