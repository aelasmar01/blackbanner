class_name Player
extends CharacterBody2D
## Player actor with movement, primary attack shell, and health.
##
## Movement: 8-directional input mapped to standard ui_* actions.
## Attack:   primary_attack() is the extension point — currently
##           spawns a simple projectile-style hit area in the
##           facing direction.
## Health:   Delegated to a HealthComponent child node.
##
## Signals flow through EventBus for cross-system listeners;
## the HealthComponent also exposes local signals for scene-level
## reactions (animations, VFX, etc.).

@export var move_speed: float = 200.0
@export var attack_cooldown: float = 0.4

@onready var health: HealthComponent = %Health
@onready var attack_timer: Timer = %AttackTimer
@onready var attack_origin: Marker2D = %AttackOrigin

## Direction the player is facing — updated every frame with
## movement input.  Defaults to right.
var facing: Vector2 = Vector2.RIGHT

## True while attack cooldown is active.
var _attack_on_cooldown: bool = false


func _ready() -> void:
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _physics_process(_delta: float) -> void:
	if health.is_dead:
		return

	_handle_movement()

	if Input.is_action_just_pressed("primary_attack") and not _attack_on_cooldown:
		primary_attack()


## --- Movement ---

func _handle_movement() -> void:
	var input_dir: Vector2 = Input.get_vector(
		"ui_left", "ui_right", "ui_up", "ui_down"
	)

	if input_dir.length_squared() > 0.0:
		facing = input_dir.normalized()

	velocity = input_dir * move_speed
	move_and_slide()


## --- Attack shell ---

## Override or extend this method to implement weapon variety.
## The base implementation creates a short-lived damage area in
## the facing direction.
func primary_attack() -> void:
	_attack_on_cooldown = true
	attack_timer.start()
	_spawn_attack_area()


func _spawn_attack_area() -> void:
	var area: Area2D = Area2D.new()
	area.name = "AttackHitbox"
	area.position = facing * 24.0

	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(20.0, 20.0)
	shape.shape = rect
	area.add_child(shape)

	area.collision_layer = 0
	area.collision_mask = 2  # enemy layer

	add_child(area)

	area.body_entered.connect(_on_attack_hit.bind(area))

	# Clean up after a short lifetime.
	get_tree().create_timer(0.15).timeout.connect(area.queue_free)


func _on_attack_hit(body: Node2D, area: Area2D) -> void:
	if body == self:
		return

	if body.has_method("take_damage"):
		var dmg: Damage = Damage.new(10.0, self, &"melee")
		body.call("take_damage", dmg)

	area.queue_free()


func _on_attack_timer_timeout() -> void:
	_attack_on_cooldown = false


## --- Damage intake (public API for external damage sources) ---

func take_damage(damage_info: Damage) -> void:
	health.take_damage(damage_info)


## --- Death ---

func _on_died() -> void:
	_event_bus().player_died.emit()
	set_physics_process(false)


func _on_damaged(damage_info: Damage) -> void:
	_event_bus().player_damaged.emit(damage_info)


func _event_bus() -> EventBusService:
	return get_node("/root/EventBus") as EventBusService
