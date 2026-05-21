# Combat Engine Architecture

This document explains the design patterns and data flow of the turn-based combat system.

## Overview

The engine uses a **component-based architecture** where combat entities (battlers) delegate responsibilities to specialized manager scripts:

```
┌─────────────────────────────────┐
│ Battle Manager (Orchestrator)   │
│ - Turn queue management         │
│ - Action resolution             │
│ - Victory/defeat detection      │
└──────────────┬──────────────────┘
               │
         ┌─────┴─────┐
         │           │
    ┌────▼────┐  ┌──▼─────┐
    │ Battler │  │ Battler │
    │         │  │         │
    │ Stats   │  │ Stats   │
    │ Manager │  │ Manager │
    │ Status  │  │ Status  │
    │ Manager │  │ Manager │
    │ Down    │  │ Down    │
    │ Manager │  │ Manager │
    └────┬────┘  └──┬─────┘
         │           │
    ┌────▼────┐  ┌──▼─────────┐
    │ Global  │  │ Resources   │
    │ Data    │  │ - Stats.tres│
    │ - React │  │ - Moves.tres│
    │ - Const │  │ - Equip.tre │
    └─────────┘  └─────────────┘
```

## Data Flow: Simple Attack

```
1. PLAN PHASE
   Player selects target and move
   
2. QUEUE PHASE  
   BattleManager.queue_action(action)
   - Action stored in queue
   
3. PROCESSING PHASE
   BattleManager._process_turn_queue()
   
4. RESOLUTION PHASE
   For each action in queue:
     a) attacker.stats_manager.calculate_damage(move, target)
     b) target.take_damage(damage)
     c) Emit signals for UI update
     
5. STATUS TICK PHASE
   For each battler:
     - status_manager.tick_all_status()
     - Ticking effects resolve (burn damage, etc.)
     
6. TURN END
   Check victory/defeat
   Advance turn queue
   Next battler's turn
```

## Data Flow: Elemental Chain Reaction

```
1. PRIMER PHASE
   - Attacker uses Water element
   - Target: affinity_manager.elemental_primer = "water"
   - Target is now "WET"
   
2. TRIGGER SETUP
   - Player targets same enemy with Electro move
   
3. REACTION CHECK
   - Check REACTION_MAP["water", "electro"]
   - Found: chain_short_circuit reaction
   - Clear primer: affinity_manager.elemental_primer = "neutral"
   
4. APPLY REACTION
   - Load chain_short_circuit resource
   - Check cooldown (prevent infinite loops)
   - Calculate damage (with chain decay if AoE)
   - Apply to target status_manager.apply_reaction()
   
5. PROXY AoE (if applicable)
   - Find all other battlers with "water" primer
   - Apply reaction at 50%, 25%, etc. damage (chain decay)
   
6. REACTION TICKING
   - status_manager ticks reaction each turn
   - Reaction damage/effects apply
   - When duration expires, reaction removed
```

## Component Responsibilities

### Battle Manager (`battlemanager.gd`)

**Responsibilities:**
- Manage turn queue (who goes when)
- Validate and execute actions
- Calculate turn order
- Detect victory/defeat
- Broadcast signals to UI

**Public Interface:**
```gdscript
func queue_action(action: Action) -> void
func add_participant(battler: Node3D) -> void
func remove_participant(battler: Node3D) -> void
func get_current_actor() -> Node3D
func get_valid_targets(actor: Node3D) -> Array[Node3D]
```

### Battler (`battler.gd`)

**Responsibilities:**
- Store visual state (sprite, model)
- Delegate calculations to managers
- Receive damage/status from manager
- Emit signals for UI feedback

**Public Interface:**
```gdscript
func take_damage(damage: int, attacker: Node3D = null) -> void
func apply_status(status: StatusEffect) -> void
func apply_reaction(reaction: StatusEffect) -> void
func heal(amount: int) -> void
```

### Stats Manager (`stats_manager.gd`)

**Responsibilities:**
- Store current/max stats
- Calculate final stats (base + equipment + buffs)
- Compute damage output
- Track crit chance and damage multipliers

**Key Methods:**
```gdscript
func get_stats_multiplier() -> float  # Equipment & buff multiplier
func calculate_damage(move: Move, target: Stats) -> int
func apply_damage(damage: int) -> void
func heal(amount: int) -> void
```

**Calculation Flow:**
```
final_stat = base_stat * equipment_multiplier * status_multiplier

Example (ATK):
- Base: 100
- Equipment bonus: +20%
- Buff ("+50% ATK"): +50%
- Final: 100 * 1.2 * 1.5 = 180 ATK
```

### Status Manager (`status_manager.gd`)

**Responsibilities:**
- Apply status effects and chain reactions
- Tick active effects each turn
- Handle status removal and cleanup
- Manage guaranteed crits and special effects

**Key Methods:**
```gdscript
func apply_status(status: StatusEffect) -> void
func apply_reaction(reaction: StatusEffect) -> void
func tick_all_status() -> void
func remove_active_reaction(reaction: StatusEffect) -> void
```

**Status Categories:**
- Regular status effects (burn, freeze, etc.)
- Chain reactions (separate tracking for display)
- Guaranteed crits (temporary flags)

### Down Manager (`down_manager.gd`)

**Responsibilities:**
- Track posture/down state
- Fill down_meter on hits
- Apply down state effects
- Reset meter after down turn

**Key Mechanics:**
- `down_meter_fill` ranges 0-100
- When >= 100: Enter Down State
- Down State: Skip next turn, reset meter
- Weakness hits fill meter more

### Affinity Manager (`affinity_manager.gd`)

**Responsibilities:**
- Track elemental primer state
- Support elemental reaction lookups
- Manage element resistance/weakness

**Key State:**
```gdscript
var elemental_primer: String = "neutral"  # "water", "fire", etc.
var element_affinities: Dictionary  # Weakness/resistance data
```

## Resource Architecture

### Stats Resource (`Stats.tres`)

```gdscript
# Base stats
var max_hp: int
var atk: int
var def: int
var spd: int
var crit_rate: float  # 0.0 to 1.0
var crit_dmg: float   # Multiplier (default 1.5)

# Affinities (weakness/resistance)
var element_affinities: Dictionary  # {"fire": 1.5, "water": 0.8}
var physical_affinities: Dictionary  # {"slash": 1.0, "blunt": 0.9}
```

### Move Resource (`Move.tres`)

```gdscript
var name: String
var description: String
var elemental_type: String  # "water", "fire", "neutral"
var damage_multiplier: float  # Damage = ATK * multiplier
var target_type: String  # "single", "all_enemies"
var mp_cost: int
var turn_cost: int  # Number of turns to execute
```

### StatusEffect Resource (`StatusEffect.tres`)

```gdscript
var name: String
var duration: int  # Turns until expiration
var is_chain_reaction: bool  # If true, tracked separately
var icon: Texture2D

# Custom properties (extend as needed)
var damage_per_turn: int
var stat_multiplier: float
var guaranteed_crit: bool
```

### Equipment Resource (`Equipment.tres`)

```gdscript
var name: String
var description: String
var equipment_type: String  # "weapon", "armor", "accessory"

# Stat bonuses
var bonus_hp: int
var bonus_atk: int
var bonus_def: int
var bonus_crit_rate: float
var bonus_crit_dmg: float
```

## Signal Flow

Battlers emit signals that UI systems listen to:

```gdscript
# In battler.gd
signal health_changed(new_health: int, max_health: int)
signal status_applied(status: StatusEffect)
signal status_removed(status: StatusEffect)
signal reaction_triggered(reaction: StatusEffect)
signal down_state_entered
signal defeated
```

BattleManager emits:

```gdscript
signal turn_started(battler: Node3D)
signal turn_ended(battler: Node3D)
signal action_resolved(action: Action)
signal battle_ended(winner: String)
```

## Elemental Reaction System Details

### Primer/Trigger Mechanism

**State Machine:**
```
NEUTRAL ──(apply "water")──> WET ──(trigger "electro")──> SHORT_CIRCUIT
                                  ────(trigger "fire")──> VAPORIZE
```

### Reaction Cooldowns

Prevents infinite reaction loops:

```gdscript
# In battler.gd
var reaction_cooldowns: Dictionary  # {"short_circuit": 2}

func _process_frame() -> void:
    for reaction_name in reaction_cooldowns.keys():
        reaction_cooldowns[reaction_name] -= 1
        if reaction_cooldowns[reaction_name] <= 0:
            reaction_cooldowns.erase(reaction_name)
```

### Chain Decay (Proxy AoE)

When a reaction triggers on multiple targets:

```
Primary target:      100% damage
Jump 1 (2nd enemy):  50% damage
Jump 2 (3rd enemy):  25% damage
Jump 3+ (4th+):      0% (no jump)
```

This prevents chain reactions from becoming too powerful while maintaining strategic depth.

## Extensibility Points

### Adding Custom Status Effects

Override `status_manager.tick_status()`:

```gdscript
func tick_status(status: StatusEffect) -> void:
    match status.name:
        "burn":
            take_damage(status.damage_per_turn)
        "frozen":
            if randf() < 0.3:  # 30% chance to thaw
                remove_status(status)
        "my_custom_effect":
            # Custom logic here
            pass
```

### Adding Custom Damage Calculations

Override `stats_manager.calculate_damage()`:

```gdscript
func calculate_damage(move: Move, target_stats: Stats) -> int:
    var base_dmg = atk * move.damage_multiplier
    var crit_mult = 1.0
    
    if randf() < crit_rate:
        crit_mult = crit_dmg
    
    # Custom weakness calculation
    var affinity_mult = target_stats.element_affinities.get(move.elemental_type, 1.0)
    
    return int(base_dmg * crit_mult * affinity_mult)
```

### Adding Custom Turn Order

Override `battlemanager._process_turn_queue()`:

```gdscript
func _calculate_turn_order() -> Array[Node3D]:
    var sorted = participants.duplicate()
    sorted.sort_custom(func(a, b):
        var a_speed = a.stats_manager.get_final_stat("spd")
        var b_speed = b.stats_manager.get_final_stat("spd")
        return a_speed > b_speed
    )
    return sorted
```

---

**Design Principle:** Data-driven, component-based, easily extensible. Add custom logic without modifying core systems.
