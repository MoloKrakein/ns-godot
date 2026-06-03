# PartyManager Usage Guide

## What is `PartyManager`?
`PartyManager` is a lightweight autoload singleton for tracking player and enemy battlers across the project.
It stores two lists:
- `player_party`
- `enemy_party`

It also emits signals when battlers are registered or unregistered.

## Setup
1. Ensure `Scripts/party_manager.gd` exists.
2. In Godot, open `Project Settings` → `Autoload`.
3. Add `res://Scripts/party_manager.gd` with the name `PartyManager`.
4. Confirm `PartyManager` appears in the autoload list.

## How battlers register
`Battler` instances in this project already try to register themselves automatically in `_ready()` if `PartyManager` exists, and unregister in `_exit_tree()`.
So most of the time you do not need to call registration manually.

If you build a new battler dynamically or manually add one, do this:
```gdscript
var battler: Battler = Battler.new()
# configure battler...
PartyManager.register_battler(battler)
```

To remove a battler from tracking:
```gdscript
PartyManager.unregister_battler(battler)
```

## API

### Properties
- `PartyManager.player_party`: Array of registered player `Battler` nodes.
- `PartyManager.enemy_party`: Array of registered enemy `Battler` nodes.

### Methods
- `register_battler(battler: Battler) -> void`
  - Adds the battler to `player_party` or `enemy_party` based on `battler.battler_type`.
  - Emits `battler_registered(battler)` when successful.

- `unregister_battler(battler: Battler) -> void`
  - Removes the battler from whichever party list contains it.
  - Emits `battler_unregistered(battler)` when successful.

- `get_player_party() -> Array`
  - Returns a duplicate of the player party list.

- `get_enemy_party() -> Array`
  - Returns a duplicate of the enemy party list.

- `clear() -> void`
  - Empties both party lists.

## Example usage

### Accessing parties from game systems
```gdscript
var players: Array = PartyManager.get_player_party()
var enemies: Array = PartyManager.get_enemy_party()
```

### Listening for party changes
```gdscript
PartyManager.connect("battler_registered", self, "_on_battler_registered")
PartyManager.connect("battler_unregistered", self, "_on_battler_unregistered")

func _on_battler_registered(battler: Battler) -> void:
	print("Registered: ", battler.stats.character_name)

func _on_battler_unregistered(battler: Battler) -> void:
	print("Unregistered: ", battler.stats.character_name)
```

## BattleManager integration
`BattleManager` is already updated to prefer `PartyManager` data when available.
If `PartyManager` is loaded, `BattleManager` does the following:
- reads `PartyManager.get_player_party()` and `PartyManager.get_enemy_party()`
- only falls back to scanning child battlers under `$PlayerParty` and `$EnemyParty` when needed

This means your battle flow can use the centralized party registry without changing existing `BattleManager` logic.

## When to use PartyManager
Use `PartyManager` when you need:
- party data shared outside the battle scene
- consistent player/enemy registration across scenes
- a central place for party queries that is not tied to a specific node tree

## Notes
- `PartyManager` does not manage active/reserve splits or turn order. That still belongs to `BattleManager`.
- It is intentionally simple: a registry, not a full party system.
