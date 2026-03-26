class_name EnemyBehaviorSelector
extends RefCounted
## Pure helper for the enemy base state flow.

const IDLE: StringName = &"idle"
const CHASE: StringName = &"chase"
const ATTACK: StringName = &"attack"
const HIT_REACTION: StringName = &"hit_reaction"


static func select_state(
		has_target: bool,
		distance_to_target: float,
		chase_range: float,
		attack_range: float,
		in_hit_reaction: bool
	) -> StringName:
	if in_hit_reaction:
		return HIT_REACTION

	if not has_target:
		return IDLE

	if distance_to_target <= attack_range:
		return ATTACK

	if distance_to_target <= chase_range:
		return CHASE

	return IDLE
