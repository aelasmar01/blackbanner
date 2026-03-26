class_name Damage
extends RefCounted
## Lightweight data object representing a single damage event.
##
## Passed into HealthComponent.take_damage() so combat systems
## can carry contextual information without coupling the health
## system to specific damage sources.

var amount: float
var source: Node
var type: StringName


func _init(
		amount_value: float = 0.0,
		source_value: Node = null,
		type_value: StringName = &"generic"
	) -> void:
	amount = amount_value
	source = source_value
	type = type_value
