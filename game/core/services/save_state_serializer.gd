class_name SaveStateSerializer
extends RefCounted

const PROFILE_KIND: String = "profile_state"
const RUN_KIND: String = "run_state"
const DATA_KEY: String = "data"


static func serialize_profile(state: ProfileState) -> Dictionary:
	return {
		"kind": PROFILE_KIND,
		"schema_version": state.schema_version,
		DATA_KEY: {
			"display_name": state.display_name,
			"unlocks": state.unlocks.duplicate(),
			"settings": state.settings.duplicate(true),
		},
	}


static func deserialize_profile(raw_data: Variant) -> ProfileState:
	var envelope: Dictionary = _read_envelope(
		raw_data,
		PROFILE_KIND,
		ProfileState.CURRENT_SCHEMA_VERSION
	)
	if envelope.is_empty():
		return null

	var payload: Dictionary = envelope[DATA_KEY]
	var schema_version: int = envelope["schema_version"]
	var display_name_value: Variant = payload.get("display_name", "")
	var settings_value: Variant = payload.get("settings", {})
	if not (display_name_value is String):
		return null
	if not (settings_value is Dictionary):
		return null

	var unlocks: Array[String] = []
	if not _try_read_string_array(payload.get("unlocks", []), unlocks):
		return null

	return ProfileState.new(
		schema_version,
		display_name_value,
		unlocks,
		settings_value
	)


static func serialize_run(state: RunState) -> Dictionary:
	return {
		"kind": RUN_KIND,
		"schema_version": state.schema_version,
		DATA_KEY: {
			"run_id": state.run_id,
			"seed": state.seed,
			"started_at_unix": state.started_at_unix,
			"encounters_completed": state.encounters_completed,
			"upgrades": state.upgrades.duplicate(),
			"is_active": state.is_active,
		},
	}


static func deserialize_run(raw_data: Variant) -> RunState:
	var envelope: Dictionary = _read_envelope(
		raw_data,
		RUN_KIND,
		RunState.CURRENT_SCHEMA_VERSION
	)
	if envelope.is_empty():
		return null

	var payload: Dictionary = envelope[DATA_KEY]
	var schema_version: int = envelope["schema_version"]
	var run_id_value: Variant = payload.get("run_id", "")
	var seed_value: Variant = payload.get("seed", 0)
	var started_at_unix_value: Variant = payload.get("started_at_unix", 0)
	var encounters_completed_value: Variant = payload.get("encounters_completed", 0)
	var is_active_value: Variant = payload.get("is_active", false)
	if not (run_id_value is String):
		return null
	if not (seed_value is int):
		return null
	if not (started_at_unix_value is int):
		return null
	if not (encounters_completed_value is int):
		return null
	if not (is_active_value is bool):
		return null

	var upgrades: Array[String] = []
	if not _try_read_string_array(payload.get("upgrades", []), upgrades):
		return null

	return RunState.new(
		schema_version,
		run_id_value,
		seed_value,
		started_at_unix_value,
		encounters_completed_value,
		upgrades,
		is_active_value
	)


static func _read_envelope(raw_data: Variant, expected_kind: String, expected_version: int) -> Dictionary:
	if not (raw_data is Dictionary):
		return {}

	var envelope: Dictionary = raw_data
	var kind_value: Variant = envelope.get("kind", "")
	var schema_version_value: Variant = envelope.get("schema_version", -1)
	var payload_value: Variant = envelope.get(DATA_KEY, null)
	if not (kind_value is String):
		return {}
	if kind_value != expected_kind:
		return {}
	if not (schema_version_value is int):
		return {}
	if schema_version_value != expected_version:
		return {}
	if not (payload_value is Dictionary):
		return {}

	return {
		"schema_version": schema_version_value,
		DATA_KEY: payload_value,
	}


static func _try_read_string_array(value: Variant, output: Array[String]) -> bool:
	if not (value is Array):
		return false

	var entries: Array = value
	output.clear()
	for entry: Variant in entries:
		if not (entry is String):
			output.clear()
			return false
		output.append(entry)

	return true
