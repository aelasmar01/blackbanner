class_name UpgradePool
extends RefCounted
## Central candidate selection service for the upgrade draft.
##
## Holds the full registry of available UpgradeDefinitions and
## provides a single entry point for requesting draft candidates.
## All filtering, duplicate prevention, and eligibility checks
## happen here so no other system needs to re-implement them.

## All registered upgrade definitions, keyed by id.
var _registry: Dictionary = {}  # String → UpgradeDefinition


## Register a single definition.  Overwrites any existing entry
## with the same id.
func register(definition: UpgradeDefinition) -> void:
	if definition == null or definition.id.is_empty():
		push_warning("UpgradePool: cannot register a null or id-less definition.")
		return
	_registry[definition.id] = definition


## Bulk-register an array of definitions.
func register_all(definitions: Array[UpgradeDefinition]) -> void:
	for def: UpgradeDefinition in definitions:
		register(def)


## Return the number of registered definitions.
func size() -> int:
	return _registry.size()


## Look up a definition by id.  Returns null if not found.
func get_definition(id: String) -> UpgradeDefinition:
	return _registry.get(id) as UpgradeDefinition


## Return all registered definitions as a flat array.
func get_all() -> Array[UpgradeDefinition]:
	var result: Array[UpgradeDefinition] = []
	for def: UpgradeDefinition in _registry.values():
		result.append(def)
	return result


## Select up to `count` eligible upgrade candidates for a draft.
##
## `owned_upgrade_ids` — ids already acquired this run (from
## RunState.upgrades), used for duplicate / max-stack prevention.
##
## `exclude_ids` — additional ids to exclude from this specific
## draft (e.g., upgrades offered in a previous reroll).
##
## Returns an array of UpgradeDefinition.  May contain fewer
## than `count` if not enough eligible candidates exist.
func select_candidates(
		count: int,
		owned_upgrade_ids: Array[String] = [],
		exclude_ids: Array[String] = []
	) -> Array[UpgradeDefinition]:

	var eligible: Array[UpgradeDefinition] = _get_eligible(
		owned_upgrade_ids, exclude_ids
	)

	# Shuffle for randomness — future work can add weighted
	# selection here without changing the public API.
	eligible.shuffle()

	var result: Array[UpgradeDefinition] = []
	var pick_count: int = mini(count, eligible.size())
	for i: int in range(pick_count):
		result.append(eligible[i])

	return result


## Return all definitions that pass eligibility checks.
func _get_eligible(
		owned_upgrade_ids: Array[String],
		exclude_ids: Array[String]
	) -> Array[UpgradeDefinition]:

	var eligible: Array[UpgradeDefinition] = []

	for def: UpgradeDefinition in _registry.values():
		if _is_excluded(def, exclude_ids):
			continue
		if _is_at_max_stacks(def, owned_upgrade_ids):
			continue
		eligible.append(def)

	return eligible


## True if the definition's id appears in the explicit exclude
## list.
func _is_excluded(
		def: UpgradeDefinition,
		exclude_ids: Array[String]
	) -> bool:
	return def.id in exclude_ids


## True if the upgrade has a max_stacks limit and the player
## already owns that many copies.
func _is_at_max_stacks(
		def: UpgradeDefinition,
		owned_upgrade_ids: Array[String]
	) -> bool:
	if def.max_stacks <= 0:
		return false

	var count: int = owned_upgrade_ids.count(def.id)
	return count >= def.max_stacks
