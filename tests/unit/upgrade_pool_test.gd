extends SceneTree
## Unit tests for UpgradePool candidate selection and
## RewardDraftService draft / select flow.


func _init() -> void:
	var failures: Array[String] = []
	_test_register_and_size(failures)
	_test_get_definition(failures)
	_test_select_candidates_returns_requested_count(failures)
	_test_select_candidates_caps_at_available(failures)
	_test_duplicate_prevention_max_stacks(failures)
	_test_exclude_ids(failures)
	_test_unlimited_stacking(failures)
	_test_empty_pool_returns_empty(failures)
	_test_draft_service_open_and_select(failures)
	_test_draft_service_rejects_invalid_selection(failures)
	_test_draft_service_dismiss(failures)

	if failures.is_empty():
		_write_result("PASS")
		print("upgrade_pool_test: PASS")
		quit(0)
		return

	_write_result("\n".join(failures))
	for failure: String in failures:
		printerr(failure)
	quit(1)


# --- Helpers ---

func _make_def(id: String, max_stacks: int = 0, rarity: int = 0) -> UpgradeDefinition:
	var def: UpgradeDefinition = UpgradeDefinition.new()
	def.id = id
	def.display_name = id
	def.description = "test"
	def.rarity = rarity
	def.max_stacks = max_stacks
	return def


func _make_pool(defs: Array[UpgradeDefinition]) -> UpgradePool:
	var pool: UpgradePool = UpgradePool.new()
	pool.register_all(defs)
	return pool


func _make_run(owned: Array[String] = []) -> RunState:
	var run: RunState = RunState.create_default()
	for id: String in owned:
		run.upgrades.append(id)
	return run


# --- Tests ---

func _test_register_and_size(failures: Array[String]) -> void:
	var pool: UpgradePool = UpgradePool.new()
	pool.register(_make_def("a"))
	pool.register(_make_def("b"))
	if pool.size() != 2:
		failures.append("Pool size should be 2 after registering 2 defs, got %d." % pool.size())


func _test_get_definition(failures: Array[String]) -> void:
	var pool: UpgradePool = _make_pool([_make_def("alpha")] as Array[UpgradeDefinition])
	var def: UpgradeDefinition = pool.get_definition("alpha")
	if def == null:
		failures.append("get_definition should return the registered def.")
		return
	if def.id != "alpha":
		failures.append("get_definition returned wrong id: '%s'." % def.id)
	if pool.get_definition("missing") != null:
		failures.append("get_definition should return null for unknown id.")


func _test_select_candidates_returns_requested_count(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [
		_make_def("a"), _make_def("b"), _make_def("c"),
		_make_def("d"), _make_def("e"),
	]
	var pool: UpgradePool = _make_pool(defs)
	var result: Array[UpgradeDefinition] = pool.select_candidates(3)
	if result.size() != 3:
		failures.append("select_candidates(3) should return 3, got %d." % result.size())


func _test_select_candidates_caps_at_available(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [_make_def("only")]
	var pool: UpgradePool = _make_pool(defs)
	var result: Array[UpgradeDefinition] = pool.select_candidates(3)
	if result.size() != 1:
		failures.append("select_candidates should cap at pool size, got %d." % result.size())


func _test_duplicate_prevention_max_stacks(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [
		_make_def("stackable", 2),
		_make_def("filler_a"),
		_make_def("filler_b"),
	]
	var pool: UpgradePool = _make_pool(defs)

	# Player already owns 2 copies of "stackable" (at max_stacks).
	var owned: Array[String] = ["stackable", "stackable"]
	var result: Array[UpgradeDefinition] = pool.select_candidates(3, owned)

	for def: UpgradeDefinition in result:
		if def.id == "stackable":
			failures.append("Max-stacked upgrade should not appear in candidates.")
			return


func _test_exclude_ids(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [
		_make_def("a"), _make_def("b"), _make_def("c"),
	]
	var pool: UpgradePool = _make_pool(defs)
	var exclude: Array[String] = ["a", "b"]
	var result: Array[UpgradeDefinition] = pool.select_candidates(3, [], exclude)
	if result.size() != 1:
		failures.append("Excluding 2 of 3 should leave 1 candidate, got %d." % result.size())
		return
	if result[0].id != "c":
		failures.append("Only 'c' should remain after excluding a and b, got '%s'." % result[0].id)


func _test_unlimited_stacking(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [_make_def("infinite", 0)]
	var pool: UpgradePool = _make_pool(defs)
	var owned: Array[String] = ["infinite", "infinite", "infinite", "infinite", "infinite"]
	var result: Array[UpgradeDefinition] = pool.select_candidates(1, owned)
	if result.size() != 1:
		failures.append("max_stacks=0 should allow unlimited, got %d candidates." % result.size())


func _test_empty_pool_returns_empty(failures: Array[String]) -> void:
	var pool: UpgradePool = UpgradePool.new()
	var result: Array[UpgradeDefinition] = pool.select_candidates(3)
	if result.size() != 0:
		failures.append("Empty pool should return 0 candidates, got %d." % result.size())


func _test_draft_service_open_and_select(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [
		_make_def("x"), _make_def("y"), _make_def("z"),
	]
	var pool: UpgradePool = _make_pool(defs)
	var service: RewardDraftService = RewardDraftService.new(pool)
	var run: RunState = _make_run()

	var draft: Array[UpgradeDefinition] = service.open_draft(run)
	if draft.size() != 3:
		failures.append("Draft should contain 3 candidates, got %d." % draft.size())
		return

	var chosen_id: String = draft[0].id
	var ok: bool = service.select(chosen_id, run)
	if not ok:
		failures.append("select() should return true for a valid draft candidate.")
		return

	if chosen_id not in run.upgrades:
		failures.append("Selected upgrade '%s' should appear in run.upgrades." % chosen_id)
	if not service.current_draft.is_empty():
		failures.append("current_draft should be cleared after selection.")


func _test_draft_service_rejects_invalid_selection(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [_make_def("a")]
	var pool: UpgradePool = _make_pool(defs)
	var service: RewardDraftService = RewardDraftService.new(pool)
	var run: RunState = _make_run()

	service.open_draft(run)
	var ok: bool = service.select("not_in_draft", run)
	if ok:
		failures.append("select() should return false for an id not in the draft.")


func _test_draft_service_dismiss(failures: Array[String]) -> void:
	var defs: Array[UpgradeDefinition] = [_make_def("a")]
	var pool: UpgradePool = _make_pool(defs)
	var service: RewardDraftService = RewardDraftService.new(pool)
	var run: RunState = _make_run()

	service.open_draft(run)
	service.dismiss()
	if not service.current_draft.is_empty():
		failures.append("current_draft should be empty after dismiss().")


func _write_result(contents: String) -> void:
	var file: FileAccess = FileAccess.open(
		"user://upgrade_pool_test_result.txt", FileAccess.WRITE
	)
	if file == null:
		return
	file.store_string(contents)
	file.close()
