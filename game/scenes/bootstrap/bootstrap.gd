extends Node
## Bootstrap entry point for the application.
##
## Ensures a profile exists (creating a default if needed),
## then transitions to the main menu scene.

const MAIN_MENU_PATH: String = "res://game/scenes/menu/main_menu.tscn"


func _ready() -> void:
	_save_manager().ensure_profile()
	_event_bus().bootstrap_finished.emit()
	_go_to_main_menu()


func _go_to_main_menu() -> void:
	var err: Error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if err != OK:
		push_error("Bootstrap: failed to transition to main menu (error %d)." % err)


func _event_bus() -> EventBusService:
	return get_node("/root/EventBus") as EventBusService


func _save_manager() -> SaveManagerService:
	return get_node("/root/SaveManager") as SaveManagerService
