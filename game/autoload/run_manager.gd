class_name RunManagerService
extends Node
## Top-level orchestrator for a single roguelike run.
##
## Responsible for:
##   - starting and ending a run
##   - holding the active run state
##   - coordinating run lifecycle signals
##
## Does NOT own encounter logic, reward logic, or combat math.

## Active run state. Null when no run is in progress.
var run_state: RunState = null

## True while a run is active.
var run_active: bool = false


func start_run() -> void:
	var state: RunState = _save_manager().create_default_run()
	state.started_at_unix = int(Time.get_unix_time_from_system())
	state.is_active = true
	set_run_state(state)
	_save_manager().save_run(run_state)
	_event_bus().run_started.emit()


func end_run() -> void:
	run_state = null
	run_active = false
	_save_manager().clear_run()
	_event_bus().run_ended.emit()


func set_run_state(state: RunState) -> void:
	run_state = state
	run_active = state != null and state.is_active


func restore_run() -> bool:
	var saved_state: RunState = _save_manager().load_run()
	if saved_state == null:
		run_state = null
		run_active = false
		return false

	set_run_state(saved_state)
	return true


func save_active_run() -> bool:
	if run_state == null:
		return false

	return _save_manager().save_run(run_state)


func _event_bus() -> EventBusService:
	return get_node("/root/EventBus") as EventBusService


func _save_manager() -> SaveManagerService:
	return get_node("/root/SaveManager") as SaveManagerService
