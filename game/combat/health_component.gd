class_name HealthComponent
extends Node
## Reusable health management component.
##
## Attach to any actor that has hit points.  Provides damage
## intake, healing, death detection, and signals for external
## listeners.  Keeps all HP math in one place so actors do not
## duplicate health bookkeeping.

signal damaged(damage_info: Damage)
signal healed(amount: float)
signal died

@export var max_hp: float = 100.0

var current_hp: float:
	get:
		return current_hp
	set(value):
		current_hp = clampf(value, 0.0, max_hp)

var is_dead: bool:
	get:
		return current_hp <= 0.0


func _ready() -> void:
	current_hp = max_hp


## Apply damage.  Returns actual damage dealt after clamping.
func take_damage(damage_info: Damage) -> float:
	if is_dead:
		return 0.0

	var hp_before: float = current_hp
	current_hp -= damage_info.amount
	var dealt: float = hp_before - current_hp

	damaged.emit(damage_info)

	if is_dead:
		died.emit()

	return dealt


## Restore health.  Returns actual amount healed after clamping.
func heal(amount: float) -> float:
	if is_dead:
		return 0.0

	var hp_before: float = current_hp
	current_hp += amount
	var restored: float = current_hp - hp_before

	if restored > 0.0:
		healed.emit(restored)

	return restored


## Reset health to max.  Intended for initialization or revive
## scenarios, not normal gameplay healing.
func reset() -> void:
	current_hp = max_hp
