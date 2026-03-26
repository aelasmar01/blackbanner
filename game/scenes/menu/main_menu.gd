extends Control
## Placeholder main menu scene.
##
## Will be expanded with real menu options in a later issue.


func _ready() -> void:
	EventBus.main_menu_entered.emit()
