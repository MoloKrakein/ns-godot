# Combat Engine Template

A clean, modular turn-based RPG combat system template built in Godot 4.6. This template provides all the core systems needed to build strategic turn-based combat with elemental interactions, status effects, and tactical positioning.

## Architecture Overview

The combat engine is built on a **component-based, data-driven architecture** where each game entity uses specialized managers:

### Core Battler Components

```
Battler (Node3D)
├── Sprite3D / Mesh (Visual)
├── stats_manager.gd (Stat calculations & multipliers)
├── status_manager.gd (Status effect & reaction application)
├── down_manager.gd (Posture/Down state management)
└── affinity_manager.gd (Elemental primer tracking)
```

### Key Systems

- **Battle Manager** (`battle_manager.gd`) - Orchestrates turn queue, action resolution
- **Global Data** (`global_data.gd`) - Central repository for reaction definitions, constants
- **Resource System** - Stats, Moves, Equipment, Status Effects, Reactions as `.tres` files
- **Elemental Chain Reactions** - Primer/Trigger system with automatic reaction application

## Getting Started

### 1. Create Your Project Structure

```
Resources/
  Party/          # Character templates
  Moves/          # Move definitions
  Equipment/      # Equipment templates
  Status Effects/ # Status effect definitions
  Reactions/      # Chain reaction definitions
```

### 2. Define Core Resources

1. **Create a Party Member** (Character Template)
   - Create a new `Stats` resource in `Resources/Party/`
   - Define base stats (HP, ATK, DEF, etc.)
   - Define elemental affinities

2. **Create Moves** 
   - Create `Move` resources in `Resources/Moves/`
   - Define move properties (damage formula, elemental type, targets)

3. **Create Equipment**
   - Create `Equipment` resources in `Resources/Equipment/`
   - Define stat bonuses and effects

### 3. Build Your Battle Arena

1. Instance the `Scenes/battle manager/battle_arena.tscn` or create your own arena scene
2. Instance battler characters using `Scenes/battler/battler.tscn`
3. Set up the BattleManager to manage the turn queue
4. Wire signals from UI to battle actions

## File Structure

```
project.godot              # Godot project config
Scripts/
  global_data.gd           # Global constants & reaction definitions
  item_database.gd         # Equipment/consumable database
  
  Battler/
    battler.gd             # Main character node
    stats_manager.gd       # Stat calculations
    status_manager.gd      # Status/reaction application
    down_manager.gd        # Posture/Down system
    affinity_manager.gd    # Elemental primer tracking
  
  battle manager/
    battlemanager.gd       # Battle orchestration

Resources/
  Stats.gd                 # Character stats resource class
  Move.gd                  # Move definition class
  Equipment.gd             # Equipment resource class
  StatusEffect.gd          # Status effect class
  Reactions/               # Chain reaction definitions
  Status Effects/
    Debuff/                # Debuff effect definitions
  Party/                   # Character templates (empty - add yours!)
  Moves/                   # Move templates (empty - add yours!)
  Equipment/               # Equipment templates (empty - add yours!)

Scenes/
  battler/
    battler.tscn           # Character prefab
    battler.gd             # Character script
  
  battle manager/
    battle_arena.tscn      # Battle scene
    battlemanager.gd       # Battle logic

addons/                    # Third-party plugins
```

## Key Concepts

### Elemental Chain Reactions

The primer/trigger system creates powerful combinations:

```
1. Apply Primer
   - "Wet" is applied to enemy
   
2. Trigger Reaction
   - Enemy hit with "Electro"
   - Reaction is triggered: "Short Circuit"
   
3. Reaction Applied
   - Damage calculated and applied
   - Status effects applied
   - Cooldown prevents infinite loops
```

All valid reaction combinations are defined in `GlobalData.REACTION_MAP`.

### Down State (Posture System)

Characters have a `down_meter_fill` that:
- Increases when hit (especially on weaknesses)
- When full → Down State (skip next turn)
- Resets after Down State
- Used strategically to control enemy turns

### Status Effects

Status effects are managed through `status_manager.gd`:
- Applied via `apply_status()` or `apply_reaction()`
- Ticked each turn with custom effects
- Can interact with other systems (guaranteed crits, stat changes, etc.)

## Customization Guide

### Adding a New Reaction Type

1. Create a new `StatusEffect.tres` resource
2. Set `is_chain_reaction = true`
3. Add your reaction to `REACTION_MAP` in `global_data.gd`
4. Implement custom logic in status ticking if needed

### Adding a New Status Effect

1. Create a new `StatusEffect.tres` resource
2. Define duration, icon, and custom properties
3. Implement effect logic in `status_manager.gd`'s `tick_status()` method

### Modifying Combat Flow

Edit `battle_manager.gd`'s turn queue system to customize:
- Turn order calculation
- Action validation
- Victory/defeat conditions

## Advanced Features

- **Proxy AoE & Chain Decay** - Elemental reactions can chain between similarly-primed targets with damage reduction
- **Reaction Cooldowns** - Prevent infinite reaction loops
- **Affinity Interactions** - Custom element interactions beyond standard reactions
- **Equipment-based Stat Bonuses** - Equip items for automatic stat scaling

## Next Steps

1. Review `Scenes/battler/battler.gd` to understand character initialization
2. Review `Scripts/battle manager/battlemanager.gd` to understand turn flow
3. Check `Scripts/global_data.gd` for reaction definitions
4. Create your first character resource and test in-engine
5. Extend with your game's unique mechanics

---

**Built for Godot 4.6+ | Turn-Based Strategy | Data-Driven Design**
