extends Node
class_name PartyManager

# Simple autoload-friendly party registry.
var player_party: Array = []
var enemy_party: Array = []

signal battler_registered(battler)
signal battler_unregistered(battler)

func register_battler(battler: Battler) -> void:
    if battler == null:
        return
    if battler.battler_type == Battler.BattlerType.PLAYER:
        if battler not in player_party:
            player_party.append(battler)
            emit_signal("battler_registered", battler)
    else:
        if battler not in enemy_party:
            enemy_party.append(battler)
            emit_signal("battler_registered", battler)

func unregister_battler(battler: Battler) -> void:
    if battler == null:
        return
    if battler in player_party:
        player_party.erase(battler)
        emit_signal("battler_unregistered", battler)
    if battler in enemy_party:
        enemy_party.erase(battler)
        emit_signal("battler_unregistered", battler)

func get_player_party() -> Array:
    return player_party.duplicate()

func get_enemy_party() -> Array:
    return enemy_party.duplicate()

func clear() -> void:
    player_party.clear()
    enemy_party.clear()
