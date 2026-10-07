extends "res://tests/test_home_exterior.gd"
## Routes, residents, doorway locks and decorative boundaries for the dream salon.


func run() -> void:
	scene = load("res://world/dreamscape.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Street/Player")
	camera = scene.get_node("Street/CameraRig/Camera")
	await frames(40)
	check(scene.speakers.size() == 4, "Lucas plus three residents are bound")
	check(
		(
			scene
			. get_node("DreamCastles")
			. find_children("*", "CollisionObject3D", true, false)
			. is_empty()
		),
		"floating castles never become playable support"
	)
	await capture("pazo-upgrade-arrival")
	for point in [
		Vector3(8.4, 0, 10.8),
		Vector3(6.7, 0, 10.8),
		Vector3(4.2, 0, 10.8),
		Vector3(0.6, 0, 10.8),
		Vector3(-0.72, 0, 4.56)
	]:
		if not await walk_to(point):
			finish()
			return
	check(player.position.y > 4.3, "salon approach is on the upper terrace")
	await capture("pazo-upgrade-terrace")
	await cross_threshold(Vector3(-2.82, 4.44, 4.56), true)
	check(scene.inside_salon and player.is_on_floor(), "walking through door arrives safely inside")
	var arrival := player.position
	await frames(20)
	check(
		scene.inside_salon and player.position.distance_to(arrival) < 0.1,
		"entry does not bounce or keep steering"
	)
	await capture("pazo-salon-arrival")
	var items := scene.get_node("Street/ItemLoop")
	var supports: Array[CollisionObject3D] = scene.item_supports(scene.active_location)
	check(
		supports.has(scene.active_location.get_node("Salon/MarbleFloor")),
		"salon floor participates in item placement"
	)
	check(
		supports.all(func(body): return not body.is_in_group("placement_obstacle")),
		"salon furniture cannot act as floor support"
	)
	check(items.active_location_id == &"lourizan", "doorways preserve location item ownership")
	if not await walk_to(Vector3(-90, 0, 1.3)):
		finish()
		return
	await capture("pazo-salon-detail")
	for path in ["Salon/BraisAnfitrion", "InesBotanica", "AlbaVisitante"]:
		var npc: Node3D = scene.active_location.get_node(path)
		player.position = npc.global_position + Vector3(1.25, 0.1, 0)
		player.velocity = Vector3.ZERO
		player.reset_physics_interpolation()
		await frames(8)
		scene.open_dialogue()
		check(
			scene.dialogue.is_open and scene.dialogue.speaker_label.text == npc.speaker_name,
			"nearby resident supplies its own conversation"
		)
		check(
			player.input_locked and npc.conversation_active, "resident conversation locks movement"
		)
		scene.close_dialogue()
	player.position = Vector3(-90, 0.06, 5.9)
	player.velocity = Vector3.ZERO
	await frames(5)
	scene.open_bag()
	scene.active_location.get_node("Salon/Exit").passage_requested.emit(
		scene.active_location.get_node("Salon/Exit")
	)
	check(scene.inside_salon, "bag modal blocks doorway transitions")
	scene.close_bag()
	await cross_threshold(Vector3(-90, 0, 7.95), false)
	check(
		not scene.inside_salon and player.is_on_floor(), "salon exit returns to supported terrace"
	)
	check(
		(
			player.position.distance_to(
				scene.active_location.get_node("TerraceReturn").global_position
			)
			< 0.2
		),
		"exit returns beyond entry trigger"
	)
	# Inspect the decorative horizon at the accessible forecourt perimeter.
	player.position = Vector3(29.2, 0.1, 30)
	player.velocity = Vector3.ZERO
	scene.camera_rig.snap_to_target()
	await frames(10)
	await capture("pazo-floating-castles")
	finish()


func cross_threshold(point: Vector3, entering: bool) -> void:
	for _frame in 100:
		if scene.inside_salon == entering:
			break
		var direction := point - player.position
		direction.y = 0
		direction = direction.normalized()
		var right := Direction.from_view(Vector2.RIGHT, camera.global_basis)
		var forward := Direction.from_view(Vector2.UP, camera.global_basis)
		var x := direction.dot(right)
		var y := direction.dot(forward)
		release_inputs()
		Input.action_press("move_right" if x > 0 else "move_left", absf(x))
		Input.action_press("move_forward" if y > 0 else "move_back", absf(y))
		await frames(1)
	release_inputs()
	await frames(8)
	check(scene.inside_salon == entering, "crossing doorway completes expected transition")


func finish() -> void:
	release_inputs()
	print("Lourizán salon: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
