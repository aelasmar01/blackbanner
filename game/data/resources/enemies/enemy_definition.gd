class_name EnemyDefinition
extends Resource
## Data-driven stats and tuning values for a reusable enemy actor.

@export var display_name: String = "Base Enemy"
@export var max_hp: float = 40.0
@export var move_speed: float = 90.0
@export var chase_range: float = 160.0
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 0.8
@export var contact_damage: float = 10.0
@export var hit_reaction_duration: float = 0.12
@export var hit_reaction_speed: float = 120.0
