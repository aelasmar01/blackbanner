extends Control
## Placeholder main menu scene.
##
## Will be expanded with real menu options in a later issue.


func _ready() -> void:
	_event_bus().main_menu_entered.emit()


func _event_bus() -> EventBusService:
	return get_node("/root/EventBus") as EventBusService
