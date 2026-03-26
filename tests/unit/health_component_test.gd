extends SceneTree
## Unit tests for HealthComponent and Damage.
##
## Tests cover: initialization, damage intake, death threshold,
## healing, clamping, and post-death rejection.


func _init() -> void:
	var failures: Array[String] = []
	_test_initial_state(failures)
	_test_take_damage(failures)
	_test_death_on_zero_hp(failures)
	_test_overkill_clamps_to_zero(failures)
	_test_heal(failures)
	_test_heal_clamps_to_max(failures)
	_test_no_damage_after_death(failures)
	_test_no_heal_after_death(failures)
	_test_damage_data_object(failures)

	if failures.is_empty():
		_write_result("PASS")
		print("health_component_test: PASS")
		quit(0)
		return

	_write_result("\n".join(failures))
	for failure: String in failures:
		printerr(failure)
	quit(1)


func _make_component(hp: float) -> HealthComponent:
	var comp: HealthComponent = HealthComponent.new()
	comp.max_hp = hp
	# Simulate _ready() initialization.
	comp.current_hp = hp
	return comp


func _make_damage(amount: float) -> Damage:
	return Damage.new(amount, null, &"test")


# --- Tests ---

func _test_initial_state(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(80.0)
	if not is_equal_approx(comp.current_hp, 80.0):
		failures.append("Initial HP should equal max_hp.")
	if comp.is_dead:
		failures.append("Component should not start dead.")


func _test_take_damage(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(100.0)
	var dealt: float = comp.take_damage(_make_damage(30.0))
	if not is_equal_approx(dealt, 30.0):
		failures.append("take_damage should return 30 dealt, got %f." % dealt)
	if not is_equal_approx(comp.current_hp, 70.0):
		failures.append("HP should be 70 after 30 damage, got %f." % comp.current_hp)


func _test_death_on_zero_hp(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(50.0)
	comp.take_damage(_make_damage(50.0))
	if not comp.is_dead:
		failures.append("Component should be dead at 0 HP.")


func _test_overkill_clamps_to_zero(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(40.0)
	var dealt: float = comp.take_damage(_make_damage(999.0))
	if not is_equal_approx(dealt, 40.0):
		failures.append("Overkill dealt should be clamped to 40, got %f." % dealt)
	if not is_equal_approx(comp.current_hp, 0.0):
		failures.append("HP should be 0 after overkill, got %f." % comp.current_hp)


func _test_heal(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(100.0)
	comp.take_damage(_make_damage(40.0))
	var restored: float = comp.heal(20.0)
	if not is_equal_approx(restored, 20.0):
		failures.append("Heal should return 20, got %f." % restored)
	if not is_equal_approx(comp.current_hp, 80.0):
		failures.append("HP should be 80 after heal, got %f." % comp.current_hp)


func _test_heal_clamps_to_max(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(100.0)
	comp.take_damage(_make_damage(10.0))
	var restored: float = comp.heal(999.0)
	if not is_equal_approx(restored, 10.0):
		failures.append("Overheal should return 10, got %f." % restored)
	if not is_equal_approx(comp.current_hp, 100.0):
		failures.append("HP should clamp to max, got %f." % comp.current_hp)


func _test_no_damage_after_death(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(50.0)
	comp.take_damage(_make_damage(50.0))
	var dealt: float = comp.take_damage(_make_damage(20.0))
	if not is_equal_approx(dealt, 0.0):
		failures.append("Damage after death should return 0, got %f." % dealt)


func _test_no_heal_after_death(failures: Array[String]) -> void:
	var comp: HealthComponent = _make_component(50.0)
	comp.take_damage(_make_damage(50.0))
	var restored: float = comp.heal(20.0)
	if not is_equal_approx(restored, 0.0):
		failures.append("Heal after death should return 0, got %f." % restored)


func _test_damage_data_object(failures: Array[String]) -> void:
	var dmg: Damage = Damage.new(25.0, null, &"fire")
	if not is_equal_approx(dmg.amount, 25.0):
		failures.append("Damage amount should be 25.")
	if dmg.source != null:
		failures.append("Damage source should be null.")
	if dmg.type != &"fire":
		failures.append("Damage type should be 'fire'.")


func _write_result(contents: String) -> void:
	var file: FileAccess = FileAccess.open(
		"user://health_component_test_result.txt", FileAccess.WRITE
	)
	if file == null:
		return
	file.store_string(contents)
	file.close()
