# Upgrade Framework

## Overview

The upgrade framework implements the post-encounter reward draft — a core roguelike loop where the player chooses one of several upgrade candidates after completing an encounter. The system is data-driven, centrally filtered, and cleanly separated between selection logic, application logic, and UI presentation.

## Architecture

```
UpgradeDefinition (.tres resources)
        │
        ▼
   UpgradePool              ← central registry + selection
        │
        ▼
 RewardDraftService          ← orchestrates draft lifecycle
        │
   ┌────┴─────┐
   ▼           ▼
RunState    RewardDraftScreen  ← upgrade applied / UI presented
```

## Components

### UpgradeDefinition (`game/data/resources/upgrades/upgrade_definition.gd`)

A `Resource` that defines a single upgrade available in the reward pool.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Unique identifier, stored in `RunState.upgrades` |
| `display_name` | `String` | Player-facing name |
| `description` | `String` | Player-facing description |
| `rarity` | `int (0-3)` | 0=common, 1=uncommon, 2=rare, 3=legendary |
| `max_stacks` | `int` | Max copies per run (0 = unlimited) |
| `tags` | `PackedStringArray` | Freeform tags for filtering hooks |

New upgrades are added by creating `.tres` files under `game/data/resources/upgrades/`.

### UpgradePool (`game/progression/upgrades/upgrade_pool.gd`)

Central registry and candidate selection service. All filtering and eligibility checks happen here.

**Key methods:**

| Method | Description |
|---|---|
| `register(def)` | Add a single definition to the registry |
| `register_all(defs)` | Bulk-register an array of definitions |
| `get_definition(id)` | Look up a definition by id |
| `select_candidates(count, owned, exclude)` | Return up to `count` eligible candidates |

**Selection rules (applied in `_get_eligible`):**

1. **Explicit exclusion** — ids in `exclude_ids` are removed (e.g., reroll scenarios)
2. **Max-stack enforcement** — if `max_stacks > 0` and the player already owns that many copies, the upgrade is ineligible
3. **Shuffle** — eligible candidates are shuffled for randomness

Future weighting by rarity, tag-based biasing, and unlock gating can be added inside `_get_eligible` and `select_candidates` without changing the public API.

### RewardDraftService (`game/run/rewards/reward_draft_service.gd`)

Stateful orchestrator for a single reward draft session.

| Method | Description |
|---|---|
| `open_draft(run_state, count)` | Generate candidates from the pool, store in `current_draft` |
| `select(upgrade_id, run_state)` | Validate the pick, append to `run_state.upgrades`, clear draft |
| `dismiss()` | Discard the draft without selecting |

The service does **not** reference autoloads directly. The caller (e.g., an encounter-flow controller) is responsible for:
- constructing the service with an `UpgradePool`
- emitting `EventBus.reward_draft_opened` after `open_draft()`
- emitting `EventBus.upgrade_selected` after `select()`
- persisting run state via `RunManager.save_active_run()` if needed

### RewardDraftScreen (`game/ui/screens/reward_draft_screen.tscn`)

UI screen that presents candidates to the player.

| Signal | Description |
|---|---|
| `selection_made(upgrade_id)` | Emitted when the player clicks a card |

**Scene structure:**

```
RewardDraftScreen (Control)
  └── PanelContainer
      └── MarginContainer
          └── VBoxContainer
              ├── TitleLabel [unique] — "Choose an Upgrade"
              ├── Spacer
              └── ChoiceContainer [unique] (HBoxContainer)
                   └── [dynamically generated Button cards]
```

The screen receives `UpgradeDefinition` objects via `show_draft()` and renders them generically — it has **no hardcoded upgrade content**.

## EventBus Signals

| Signal | Payload | Emitted by |
|---|---|---|
| `reward_draft_opened` | `Array[UpgradeDefinition]` | Caller after `open_draft()` |
| `upgrade_selected` | `String` (upgrade id) | Caller after `select()` |

## Typical Flow

```gdscript
# 1. Build pool (once, at run start or load time)
var pool := UpgradePool.new()
pool.register_all(loaded_definitions)

# 2. Create service
var draft_service := RewardDraftService.new(pool)

# 3. After encounter completes — open draft
var candidates := draft_service.open_draft(RunManager.run_state)
EventBus.reward_draft_opened.emit(candidates)
reward_screen.show_draft(candidates)

# 4. Player selects
func _on_selection_made(upgrade_id: String) -> void:
    draft_service.select(upgrade_id, RunManager.run_state)
    EventBus.upgrade_selected.emit(upgrade_id)
    RunManager.save_active_run()
```

## Sample Definitions

| File | ID | Name | Rarity | Max Stacks |
|---|---|---|---|---|
| `speed_boost.tres` | `speed_boost` | Swift Stride | Common | 3 |
| `attack_power.tres` | `attack_power` | Sharpened Edge | Common | 3 |
| `max_health.tres` | `max_health` | Vitality Surge | Uncommon | 2 |
| `critical_strike.tres` | `critical_strike` | Lethal Precision | Rare | 1 |

## Extension Points

- **Rarity weighting**: Add weighted selection inside `UpgradePool.select_candidates()` using `def.rarity`
- **Tag-based filtering**: Use `def.tags` in `_get_eligible()` to bias or exclude categories
- **Unlock gating**: Check `ProfileState.unlocks` against a required-unlock field on `UpgradeDefinition`
- **Synergy bonuses**: Inspect `run_state.upgrades` for tag combinations that boost certain candidates
- **Reroll**: Call `open_draft()` again with previous candidates in `exclude_ids`
- **Effect application**: Gameplay systems resolve upgrade ids from `RunState.upgrades` to apply actual stat changes — the framework stores ids, not effects

## Design Decisions

- **IDs in RunState, not full objects**: `RunState.upgrades` stores `Array[String]` of ids. This keeps the save schema simple and decouples persistence from resource definitions.
- **No autoload coupling in services**: `UpgradePool` and `RewardDraftService` are plain `RefCounted` objects. They can be constructed and tested without the engine's autoload system.
- **UI has no content knowledge**: The draft screen renders whatever definitions it receives. Adding new upgrades requires only a new `.tres` file and pool registration.
- **Central filtering**: All eligibility logic lives in `UpgradePool._get_eligible()`. No other system needs to re-implement duplicate checks or stack limits.
