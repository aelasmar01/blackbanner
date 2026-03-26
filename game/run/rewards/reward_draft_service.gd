class_name RewardDraftService
extends RefCounted
## Orchestrates a single post-encounter reward draft.
##
## Requests candidates from an UpgradePool, holds the current
## draft offer, and applies the selected upgrade to a RunState.
## This service owns no UI — the UI reads the draft and calls
## back into select().

const DEFAULT_DRAFT_SIZE: int = 3

var _pool: UpgradePool

## The current set of offered candidates.  Empty when no draft
## is active.
var current_draft: Array[UpgradeDefinition] = []


func _init(pool: UpgradePool) -> void:
	_pool = pool


## Generate a new draft of `count` candidates based on the
## player's current run state.
##
## Returns the candidates (also stored in `current_draft`).
## Emits EventBus.reward_draft_opened via the caller — this
## service has no direct autoload reference.
func open_draft(
		run_state: RunState,
		count: int = DEFAULT_DRAFT_SIZE
	) -> Array[UpgradeDefinition]:

	var owned: Array[String] = run_state.upgrades.duplicate()
	current_draft = _pool.select_candidates(count, owned)
	return current_draft


## Apply the chosen upgrade to the run state.
##
## Returns true if the upgrade was valid and applied.  The
## caller is responsible for persisting run state and emitting
## EventBus.upgrade_selected afterward.
func select(
		upgrade_id: String,
		run_state: RunState
	) -> bool:

	var found: bool = false
	for def: UpgradeDefinition in current_draft:
		if def.id == upgrade_id:
			found = true
			break

	if not found:
		push_warning("RewardDraftService: '%s' is not in the current draft." % upgrade_id)
		return false

	run_state.upgrades.append(upgrade_id)
	current_draft.clear()
	return true


## Discard the current draft without selecting anything.
func dismiss() -> void:
	current_draft.clear()
