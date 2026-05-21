extends Resource
class_name Consumable

@export var id: String = "" # Unique item id, e.g. itm_health_potion
@export var item_name: String = "" # Friendly name shown in UI
@export var description: String = "" # Long description for tooltips / UI

@export_group("Targeting")
enum TargetScope { SELF, LOWEST_ALLY, SINGLE_ALLY, ALL_ALLIES, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE }
@export var target_scope: TargetScope = TargetScope.SELF

@export_group("Healing Data")
@export var heals_hp: int = 0 # Flat HP heal applied per target
@export var heals_mp: int = 0 # Flat MP heal applied per target

@export_group("Cure")
@export var cures_status: bool = false # If true, clears all status effects from the target(s)
@export var cures_specific: Array[String] = [] # Optional list of specific status IDs to remove (future)

@export_group("Effects")
@export var applied_buff: StatusEffect # Applied to target(s) as a status (use StatusEffect resources)
@export var applied_debuff: StatusEffect # Applied to target(s) as a debuff

@export_group("UI / Metadata")
@export var icon_path: String = "" # res:// path to icon for inventory UI
@export var rarity: int = 0 # Numeric rarity for sorting/filtering in UI
@export var stackable: bool = true # Whether multiple of this item stack in inventory

# Template / Notes for designers (not used at runtime):
# - Consider adding `hp_percent` or `mp_percent` for percent-based heals.
# - Use `target_scope` to indicate how a BattleManager should route this item.
# - Status application is performed via `StatusManager.apply_status_effect`, which will duplicate the StatusEffect instance.
