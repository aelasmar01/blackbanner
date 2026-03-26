extends SceneTree


func _init() -> void:
	var failures: Array[String] = []
	_test_profile_roundtrip(failures)
	_test_run_roundtrip(failures)
	_test_invalid_profile_data(failures)
	_test_invalid_run_data(failures)

	if failures.is_empty():
		_write_result("PASS")
		print("save_state_serialization_test: PASS")
		quit(0)
		return

	_write_result("\n".join(failures))
	for failure: String in failures:
		printerr(failure)
	quit(1)


func _test_profile_roundtrip(failures: Array[String]) -> void:
	var original: ProfileState = ProfileState.new(
		ProfileState.CURRENT_SCHEMA_VERSION,
		"Rook",
		["dash_unlocked"],
		{"music_volume": 0.5}
	)
	var serialized: Dictionary = SaveStateSerializer.serialize_profile(original)
	var restored: ProfileState = SaveStateSerializer.deserialize_profile(serialized)
	if restored == null:
		failures.append("Profile roundtrip returned null.")
		return

	if restored.schema_version != ProfileState.CURRENT_SCHEMA_VERSION:
		failures.append("Profile schema version was not preserved.")
	if restored.display_name != "Rook":
		failures.append("Profile display_name was not restored.")
	if restored.unlocks != ["dash_unlocked"]:
		failures.append("Profile unlocks were not restored.")
	if restored.settings.get("music_volume") != 0.5:
		failures.append("Profile settings were not restored.")


func _test_run_roundtrip(failures: Array[String]) -> void:
	var original: RunState = RunState.new(
		RunState.CURRENT_SCHEMA_VERSION,
		"run-001",
		42,
		123456,
		3,
		["reroll"],
		true
	)
	var serialized: Dictionary = SaveStateSerializer.serialize_run(original)
	var restored: RunState = SaveStateSerializer.deserialize_run(serialized)
	if restored == null:
		failures.append("Run roundtrip returned null.")
		return

	if restored.schema_version != RunState.CURRENT_SCHEMA_VERSION:
		failures.append("Run schema version was not preserved.")
	if restored.run_id != "run-001":
		failures.append("Run id was not restored.")
	if restored.seed != 42:
		failures.append("Run seed was not restored.")
	if restored.started_at_unix != 123456:
		failures.append("Run started_at_unix was not restored.")
	if restored.encounters_completed != 3:
		failures.append("Run encounters_completed was not restored.")
	if restored.upgrades != ["reroll"]:
		failures.append("Run upgrades were not restored.")
	if restored.is_active != true:
		failures.append("Run active flag was not restored.")


func _test_invalid_profile_data(failures: Array[String]) -> void:
	var invalid_payload: Dictionary = {
		"kind": SaveStateSerializer.PROFILE_KIND,
		"schema_version": ProfileState.CURRENT_SCHEMA_VERSION,
		"data": {
			"display_name": "Rook",
			"unlocks": [123],
			"settings": {},
		},
	}
	if SaveStateSerializer.deserialize_profile(invalid_payload) != null:
		failures.append("Invalid profile payload should fail to deserialize.")


func _test_invalid_run_data(failures: Array[String]) -> void:
	var invalid_payload: Dictionary = {
		"kind": SaveStateSerializer.RUN_KIND,
		"schema_version": 99,
		"data": {
			"run_id": "run-001",
			"seed": 1,
			"started_at_unix": 2,
			"encounters_completed": 3,
			"upgrades": [],
			"is_active": true,
		},
	}
	if SaveStateSerializer.deserialize_run(invalid_payload) != null:
		failures.append("Unsupported run schema version should fail to deserialize.")


func _write_result(contents: String) -> void:
	var file: FileAccess = FileAccess.open("user://save_state_test_result.txt", FileAccess.WRITE)
	if file == null:
		return

	file.store_string(contents)
	file.close()
