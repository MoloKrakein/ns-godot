# Using the Combat Engine Template

This document guides you through setting up a new project using the combat engine template.

## Step 1: Clean Up Project-Specific Content

The following items are **project-specific and should be removed** for your new game:

```
DELETE THESE FOLDERS:
├── Art/                              # Delete - contains template artwork
├── Models/                           # Delete - contains template 3D models
├── Exported_Code_Logs/               # Delete - development logs

DELETE THESE FILES:
├── Scenes/Battle_Arena3D_Test.tscn   # Delete - test arena
├── Scenes/UI/                        # Delete - specific UI implementations
├── Scripts/phone_ui_test.gd          # Delete - test script
├── Scripts/test_combat_gym.gd        # Delete - test script
├── Scripts/radial_menu_Test.gd       # Delete - test script
├── *.translation files               # Delete - translation data

EMPTY THESE FOLDERS (structure kept):
├── Resources/Party/                  # Add your characters here
├── Resources/Moves/                  # Add your moves here
├── Resources/Equipment/              # Add your equipment here
```

## Step 2: Organize Your Resources

Create your game content in these folders:

### Resources/Party/
Create character templates (Stats resources):
- `Player_Commander.tres` - Player character
- `NPC_Ally_01.tres` - Ally character
- etc.

### Resources/Moves/
Define all available moves:
- `move_basic_attack.tres`
- `move_fireball.tres`
- `move_heal.tres`
- etc.

### Resources/Equipment/
Define equipment pieces:
- `sword_iron.tres`
- `armor_leather.tres`
- etc.

### Resources/Reactions/
These chain reactions are predefined. Customize:
- Review each `chain_*.tres` file
- Adjust damage multipliers, status durations, etc.
- Rename or create new reactions as needed

## Step 3: Update Global Configuration

Edit `Scripts/global_data.gd`:

1. **Update Reaction Map** - Ensure all elemental combinations work for your game
   ```gdscript
   var REACTION_MAP: Dictionary = {
       # [PRIMER_ELEMENT, TRIGGER_ELEMENT]: REACTION_RESOURCE
       ["water", "electro"]: chain_short_circuit,
       # Add your custom reactions...
   }
   ```

2. **Add Game Constants** - Define values your game uses
   ```gdscript
   const BASE_SPEED: int = 100
   const CRIT_MULTIPLIER: float = 1.5
   # etc.
   ```

## Step 4: Create Your Battle Scenes

### Option A: Use the Provided Battle Arena

1. Open `Scenes/battle manager/battle_arena.tscn`
2. Modify to fit your art style
3. Wire UI elements to the battle manager signals

### Option B: Create Your Own

1. Create a new scene with a root `Node3D` or `Node2D`
2. Instance the `Scenes/battle manager/battlemanager.gd` script
3. Instance battler characters from `Scenes/battler/battler.tscn`
4. Create UI layer for player input
5. Wire signals between battler → manager → UI

## Step 5: Instantiate Characters

In your battle setup code:

```gdscript
# Load a character template
var player_stats = load("res://Resources/Party/Player_Commander.tres") as Stats

# Create battler instance
var battler_scene = load("res://Scenes/battler/battler.tscn")
var battler = battler_scene.instantiate()
battler.set_stats(player_stats)
add_child(battler)

# Add to battle manager
battle_manager.add_participant(battler)
```

## Step 6: Implement Your UI

Wire user input to battle actions:

```gdscript
func _on_attack_button_pressed(target: Node):
    var action = Action.new()
    action.type = Action.TYPE.ATTACK
    action.actor = player_battler
    action.targets = [target]
    battle_manager.queue_action(action)
```

## Step 7: Customize Battle Flow

Edit `Scripts/battle manager/battlemanager.gd`:

- Modify turn order calculation (`_process_turn_queue()`)
- Customize action resolution (`resolve_action()`)
- Add end-battle conditions (`_check_victory()`, `_check_defeat()`)
- Implement difficulty settings

## Advanced Customization

### Adding New Status Effects

1. Create a new `StatusEffect.tres` in `Resources/Status Effects/`
2. Define duration and icon
3. Add custom tick logic in `status_manager.gd`:
   ```gdscript
   func tick_status(status: StatusEffect) -> void:
       if status.name == "my_custom_status":
           # Custom tick behavior
   ```

### Adding New Elemental Reactions

1. Create a new `StatusEffect.tres` with `is_chain_reaction = true`
2. Set damage scaling, duration, and effects
3. Add to `REACTION_MAP` in `global_data.gd`
4. Implement damage calculation if needed

### Modifying Stat Calculations

Edit `stats_manager.gd` to customize:
- Base stat scaling
- Equipment bonuses
- Buff/debuff multipliers
- Crit calculations

## Common Workflows

### Creating a Character

1. Create new `Stats` resource: `Right-click → New Resource → Stats`
2. Set base values (HP, ATK, DEF, etc.)
3. Set element affinities
4. Save as `Resources/Party/MyCharacter.tres`

### Creating a Move

1. Create new `Move` resource
2. Set damage formula: `damage = ATK_STAT * move.damage_multiplier`
3. Set elemental type and targets
4. Save to `Resources/Moves/`

### Setting Up a Battle

1. Create scene with Node3D root
2. Add `battlemanager.gd` script
3. Instance battlers and add to manager
4. Add UI layer for controls
5. Connect signals and test!

## Troubleshooting

- **Characters not taking damage?** Check `stats_manager.gd` calculation
- **Reactions not triggering?** Verify `REACTION_MAP` contains the combination
- **Status effects not applying?** Check `status_manager.gd` for the effect type
- **Battle won't start?** Ensure battlers are added to battle manager

---

**Ready to build your game!** 🎮
