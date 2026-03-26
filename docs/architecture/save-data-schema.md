# Save Data Schema

## Ownership

- `GameState` owns the in-memory `ProfileState`.
- `RunManager` owns the in-memory `RunState`.
- `SaveManager` owns filesystem persistence for both save files.
- `SaveStateSerializer` owns the serialized schema shape and version checks.

This keeps save schema details centralized in the persistence layer instead of spreading them across gameplay systems.

## File Layout

Profile data is stored in `user://profile.save`.
Run data is stored in `user://run.save`.

Both files use the same top-level envelope:

```json
{
  "kind": "profile_state",
  "schema_version": 1,
  "data": {}
}
```

The `kind` field identifies the model type, `schema_version` gates future migrations, and `data` contains the model payload.

## ProfileState Fields

- `display_name: String`
- `unlocks: Array[String]`
- `settings: Dictionary`

Default profile state is created deterministically through `ProfileState.create_default()`.

## RunState Fields

- `run_id: String`
- `seed: int`
- `started_at_unix: int`
- `encounters_completed: int`
- `upgrades: Array[String]`
- `is_active: bool`

Default run state is created deterministically through `RunState.create_default()`. `RunManager.start_run()` fills runtime-specific values such as `started_at_unix` after creating that default model.

## Versioning Strategy

- Version `1` is the current supported schema for both model types.
- Deserialization rejects unsupported or malformed payloads and returns `null`.
- `SaveManager.ensure_profile()` falls back to a fresh default profile if loading fails.
- Run restoration fails safely by returning no state when the save file is missing or invalid.

The current implementation does not add migration steps yet. When a future schema changes, add a targeted migrator path in `SaveStateSerializer` keyed by `schema_version` before widening support.
