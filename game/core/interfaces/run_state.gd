class_name RunState
extends RefCounted

const CURRENT_SCHEMA_VERSION: int = 1

var schema_version: int
var run_id: String
var seed: int
var started_at_unix: int
var encounters_completed: int
var upgrades: Array[String]
var is_active: bool


func _init(
		schema_version_value: int = CURRENT_SCHEMA_VERSION,
		run_id_value: String = "",
		seed_value: int = 0,
		started_at_unix_value: int = 0,
		encounters_completed_value: int = 0,
		upgrades_value: Array[String] = [],
		is_active_value: bool = false
	) -> void:
	schema_version = schema_version_value
	run_id = run_id_value
	seed = seed_value
	started_at_unix = started_at_unix_value
	encounters_completed = encounters_completed_value
	upgrades = upgrades_value.duplicate()
	is_active = is_active_value


static func create_default() -> RunState:
	return RunState.new()
