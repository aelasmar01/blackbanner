class_name SaveManagerService
extends Node
## Handles filesystem persistence for versioned profile and run state.
##
## Responsible for:
##   - creating deterministic default states
##   - loading state data from disk
##   - saving state data to disk
##
## Does NOT own in-memory state -- that belongs to GameState and RunManager.
## Save schema structure is centralized in SaveStateSerializer.

const PROFILE_SAVE_PATH: String = "user://profile.save"
const RUN_SAVE_PATH: String = "user://run.save"


func create_default_profile() -> ProfileState:
	return ProfileState.create_default()


func create_default_run() -> RunState:
	return RunState.create_default()


func profile_save_exists() -> bool:
	return FileAccess.file_exists(PROFILE_SAVE_PATH)


func run_save_exists() -> bool:
	return FileAccess.file_exists(RUN_SAVE_PATH)


func load_profile() -> ProfileState:
	var raw_data: Variant = _read_save_file(PROFILE_SAVE_PATH, "profile")
	if raw_data == null:
		return null

	var state: ProfileState = SaveStateSerializer.deserialize_profile(raw_data)
	if state == null:
		push_warning("SaveManager: profile save data is invalid or unsupported.")
	return state


func save_profile(state: ProfileState) -> bool:
	if state == null:
		push_warning("SaveManager: refusing to save a null profile state.")
		return false

	var saved: bool = _write_save_file(
		PROFILE_SAVE_PATH,
		SaveStateSerializer.serialize_profile(state),
		"profile"
	)
	if saved:
		_event_bus().profile_saved.emit()
	return saved


func load_run() -> RunState:
	var raw_data: Variant = _read_save_file(RUN_SAVE_PATH, "run")
	if raw_data == null:
		return null

	var state: RunState = SaveStateSerializer.deserialize_run(raw_data)
	if state == null:
		push_warning("SaveManager: run save data is invalid or unsupported.")
	return state


func save_run(state: RunState) -> bool:
	if state == null:
		push_warning("SaveManager: refusing to save a null run state.")
		return false

	return _write_save_file(
		RUN_SAVE_PATH,
		SaveStateSerializer.serialize_run(state),
		"run"
	)


func clear_run() -> bool:
	if not run_save_exists():
		return true

	var err: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(RUN_SAVE_PATH))
	if err != OK:
		push_warning("SaveManager: failed to clear run save (error %d)." % err)
		return false

	return true


## Bootstrap helper: load existing profile or create and save a
## default one. Populates GameState with the result.
func ensure_profile() -> void:
	var state: ProfileState = load_profile()

	if state == null:
		state = create_default_profile()
		save_profile(state)

	_game_state().set_profile(state)
	_event_bus().profile_loaded.emit(state)


func _read_save_file(path: String, label: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: could not open %s save file for reading." % label)
		return null

	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_warning("SaveManager: failed to parse %s save file: %s" % [label, json.get_error_message()])
		return null

	return json.data


func _write_save_file(path: String, data: Dictionary, label: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not open %s save file for writing." % label)
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func _event_bus() -> EventBusService:
	return get_node("/root/EventBus") as EventBusService


func _game_state() -> GameStateService:
	return get_node("/root/GameState") as GameStateService
