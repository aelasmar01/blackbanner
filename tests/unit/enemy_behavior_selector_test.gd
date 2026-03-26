extends SceneTree


func _init() -> void:
	var failures: Array[String] = []
	_test_no_target_is_idle(failures)
	_test_target_in_chase_range_selects_chase(failures)
	_test_target_in_attack_range_selects_attack(failures)
	_test_target_outside_chase_range_selects_idle(failures)
	_test_hit_reaction_overrides_other_states(failures)

	if failures.is_empty():
		_write_result("PASS")
		print("enemy_behavior_selector_test: PASS")
		quit(0)
		return

	_write_result("\n".join(failures))
	for failure: String in failures:
		printerr(failure)
	quit(1)


func _test_no_target_is_idle(failures: Array[String]) -> void:
	var state: StringName = EnemyBehaviorSelector.select_state(
		false,
		INF,
		150.0,
		20.0,
		false
	)
	if state != EnemyBehaviorSelector.IDLE:
		failures.append("No target should select idle.")


func _test_target_in_chase_range_selects_chase(failures: Array[String]) -> void:
	var state: StringName = EnemyBehaviorSelector.select_state(
		true,
		100.0,
		150.0,
		20.0,
		false
	)
	if state != EnemyBehaviorSelector.CHASE:
		failures.append("Target inside chase range should select chase.")


func _test_target_in_attack_range_selects_attack(failures: Array[String]) -> void:
	var state: StringName = EnemyBehaviorSelector.select_state(
		true,
		12.0,
		150.0,
		20.0,
		false
	)
	if state != EnemyBehaviorSelector.ATTACK:
		failures.append("Target inside attack range should select attack.")


func _test_target_outside_chase_range_selects_idle(failures: Array[String]) -> void:
	var state: StringName = EnemyBehaviorSelector.select_state(
		true,
		220.0,
		150.0,
		20.0,
		false
	)
	if state != EnemyBehaviorSelector.IDLE:
		failures.append("Target outside chase range should select idle.")


func _test_hit_reaction_overrides_other_states(failures: Array[String]) -> void:
	var state: StringName = EnemyBehaviorSelector.select_state(
		true,
		10.0,
		150.0,
		20.0,
		true
	)
	if state != EnemyBehaviorSelector.HIT_REACTION:
		failures.append("Hit reaction should override attack/chase selection.")


func _write_result(contents: String) -> void:
	var file: FileAccess = FileAccess.open(
		"user://enemy_behavior_selector_test_result.txt", FileAccess.WRITE
	)
	if file == null:
		return
	file.store_string(contents)
	file.close()
