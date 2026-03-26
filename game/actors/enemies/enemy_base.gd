class_name EnemyBase
extends CharacterBody2D
## Reusable enemy actor driven by an EnemyDefinition resource.
##
## The base actor owns movement, attack timing, hit reaction, and
## health delegation. Content-specific tuning lives in the
## definition resource, not in the scene script.

signal attacked(target: Node2D, damage_info: Damage)
signal defeated(enemy: EnemyBase)
signal state_changed(previous_state: StringName, next_state: StringName)

@export var definition: EnemyDefinition
@export_node_path("Node2D") var target_path: NodePath

@onready var health: HealthComponent = %Health
@onready var attack_timer: Timer = %AttackTimer
@onready var hit_reaction_timer: Timer = %HitReactionTimer

var current_state: StringName = EnemyBehaviorSelector.IDLE
var target: Node2D = null
var _hit_reaction_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	_ensure_definition()
	_resolve_target()

	health.max_hp = definition.max_hp
	health.reset()
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)

	attack_timer.one_shot = true
	attack_timer.wait_time = definition.attack_cooldown

	hit_reaction_timer.one_shot = true
	hit_reaction_timer.wait_time = definition.hit_reaction_duration
	hit_reaction_timer.timeout.connect(_on_hit_reaction_timeout)


func _physics_process(_delta: float) -> void:
	if health.is_dead:
		velocity = Vector2.ZERO
		return

	_resolve_target()
	_update_state()

	match current_state:
		EnemyBehaviorSelector.IDLE:
			velocity = Vector2.ZERO
		EnemyBehaviorSelector.CHASE:
			_chase_target()
		EnemyBehaviorSelector.ATTACK:
			velocity = Vector2.ZERO
			_attack_target()
		EnemyBehaviorSelector.HIT_REACTION:
			velocity = _hit_reaction_velocity

	move_and_slide()


func set_target(target_node: Node2D) -> void:
	target = target_node


func take_damage(damage_info: Damage) -> float:
	return health.take_damage(damage_info)


func _ensure_definition() -> void:
	if definition == null:
		definition = EnemyDefinition.new()


func _resolve_target() -> void:
	if target != null and is_instance_valid(target):
		return

	if target_path.is_empty():
		target = null
		return

	var target_node: Node = get_node_or_null(target_path)
	if target_node is Node2D:
		target = target_node
	else:
		target = null


func _update_state() -> void:
	var next_state: StringName = EnemyBehaviorSelector.select_state(
		_has_target(),
		_distance_to_target(),
		definition.chase_range,
		definition.attack_range,
		not hit_reaction_timer.is_stopped()
	)
	_set_state(next_state)


func _set_state(next_state: StringName) -> void:
	if current_state == next_state:
		return

	var previous_state: StringName = current_state
	current_state = next_state
	state_changed.emit(previous_state, next_state)


func _has_target() -> bool:
	return target != null and is_instance_valid(target)


func _distance_to_target() -> float:
	if not _has_target():
		return INF

	return global_position.distance_to(target.global_position)


func _chase_target() -> void:
	if not _has_target():
		velocity = Vector2.ZERO
		return

	var move_direction: Vector2 = global_position.direction_to(target.global_position)
	velocity = move_direction * definition.move_speed


func _attack_target() -> void:
	if not _has_target():
		return

	if not attack_timer.is_stopped():
		return

	if _distance_to_target() > definition.attack_range:
		return

	if not target.has_method("take_damage"):
		return

	attack_timer.start()

	var damage_info: Damage = Damage.new(
		definition.contact_damage,
		self,
		&"contact"
	)
	target.call("take_damage", damage_info)
	attacked.emit(target, damage_info)


func _on_damaged(damage_info: Damage) -> void:
	var direction: Vector2 = Vector2.ZERO
	if damage_info.source is Node2D:
		var source_node: Node2D = damage_info.source as Node2D
		direction = source_node.global_position.direction_to(global_position)

	_hit_reaction_velocity = direction * definition.hit_reaction_speed
	hit_reaction_timer.start()
	_set_state(EnemyBehaviorSelector.HIT_REACTION)


func _on_hit_reaction_timeout() -> void:
	_hit_reaction_velocity = Vector2.ZERO


func _on_died() -> void:
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	defeated.emit(self)
