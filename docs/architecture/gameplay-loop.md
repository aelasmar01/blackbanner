# Gameplay Loop & Autoload Ownership

## Autoload Responsibilities

### EventBus (`game/autoload/event_bus.gd`)
- Central signal hub for decoupled cross-system communication.
- Holds signal declarations only — no state, no logic.
- Systems emit and subscribe here instead of holding direct references.

### GameState (`game/autoload/game_state.gd`)
- Owns the authoritative in-memory profile data (`profile: ProfileState`).
- Read by any system that needs profile info.
- Written to only by `SaveManager` (on load) or systems that mutate profile state and then request a save.
- Never touches the filesystem directly.

### SaveManager (`game/autoload/save_manager.gd`)
- Reads and writes versioned profile and run save files as JSON.
- Creates deterministic default `ProfileState` and `RunState` models when needed.
- Uses a serializer envelope with `kind`, `schema_version`, and `data` fields to support future migrations.
- After loading or creating a profile, populates `GameState` and emits `EventBus.profile_loaded`.

### RunManager (`game/autoload/run_manager.gd`)
- Orchestrates the lifecycle of a single roguelike run (start / end).
- Holds the active `run_state: RunState` while a run is in progress.
- Persists the active run through `SaveManager`.
- Emits `EventBus.run_started` and `EventBus.run_ended`.
- Does **not** own encounter logic, rewards, or combat math.

## High-Level Flow

```
Engine start
  → Autoloads initialized (EventBus, GameState, SaveManager, RunManager)
  → Bootstrap scene
      → ensure_profile (load or create default)
      → transition to Main Menu
  → Main Menu
      → [future] player starts a run via RunManager.start_run()
      → [future] encounters, rewards, progression
      → [future] run ends via RunManager.end_run()
      → return to Main Menu
```

## Design Constraints

- Autoloads must remain **narrow** — one clear area of ownership each.
- No combat math, encounter logic, or UI layout in autoloads.
- Save schema ownership stays centralized in the persistence layer (`SaveManager` + `SaveStateSerializer`), not scattered across gameplay classes.
