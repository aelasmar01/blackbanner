class_name ProfileState
extends RefCounted

const CURRENT_SCHEMA_VERSION: int = 1

var schema_version: int
var display_name: String
var unlocks: Array[String]
var settings: Dictionary


func _init(
		schema_version_value: int = CURRENT_SCHEMA_VERSION,
		display_name_value: String = "Adventurer",
		unlocks_value: Array[String] = [],
		settings_value: Dictionary = {}
	) -> void:
	schema_version = schema_version_value
	display_name = display_name_value
	unlocks = unlocks_value.duplicate()
	settings = settings_value.duplicate(true)


static func create_default() -> ProfileState:
	return ProfileState.new()
