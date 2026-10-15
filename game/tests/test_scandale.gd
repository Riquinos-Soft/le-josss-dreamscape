extends SceneTree
# gdlint:disable=private-method-call

const Direction = preload("res://player/movement_direction.gd")
const Jokes = preload("res://dialogue/scandale_jokes.gd")
var checks := 0
var failures := 0
var session: Node3D
var player: CharacterBody3D


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	session = load("res://world/dreamscape.tscn").instantiate()
	root.add_child(session)
	current_scene = session
	await frames(30)
	player = session.player
	var identity := player.get_instance_id()
	player.global_position = (
		session.active_location.get_node("Exit").global_position + Vector3.UP * 0.1
	)
	await frames(8)
	session.open_map()
	session.map_ui.select(&"scandale")
	check(session.map_ui.selected == &"scandale", "map offers Bar Scandale")
	check(await session.travel_to(&"scandale"), "safe arrival at Scandale")
	await frames(10)
	check(player.get_instance_id() == identity, "travel preserves player identity")
	check(player.is_on_floor(), "arrival is grounded")
	var bartender: Node3D = session.active_location.get_node("Bartender")
	check(not session.can_open_dialogue(), "cannot talk from entrance")
	check(
		session.item_supports(session.active_location).has(
			session.active_location.get_node("Floor")
		),
		"floor remains an item support"
	)
	session.get_node("Daylight").preview_hour = 13
	session.get_node("Daylight")._update_light()
	await capture("arrival-day")
	check(await walk_to(Vector3(0.4, 0, -0.5)), "controller walks clear customer aisle")
	check(session.can_open_dialogue(), "bartender reachable across solid counter")
	var body_query := PhysicsRayQueryParameters3D.create(
		Vector3(0.6, 0.5, -0.5), Vector3(-1.2, 0.5, -0.5), 1
	)
	check(
		not session.get_world_3d().direct_space_state.intersect_ray(body_query).is_empty(),
		"counter blocks body-height ray"
	)
	var before: Vector3 = player.global_position
	await walk_toward(Vector3(-2, 0, -0.5), 90)
	check(player.global_position.x > -0.3, "controller cannot walk through counter")
	check(player.global_position.distance_to(before) < 1.0, "counter stops advance")
	check(session.can_open_dialogue(), "counter does not block eye-level conversation")
	var e := InputEventKey.new()
	e.physical_keycode = KEY_E
	e.pressed = true
	root.push_input(e, true)
	await frames(3)
	check(session.dialogue.is_open and player.input_locked, "E opens joke and locks movement")
	check(session.dialogue.speaker_label.text == "Camarero del Scandale", "correct speaker")
	var first: String = session.dialogue.pages[0]
	await capture("dialogue-day")
	session.close_dialogue()
	session.touch_controls.talk_requested.emit()
	await frames(3)
	check(session.dialogue.is_open, "touch talk action shares dialogue")
	check(first != session.dialogue.pages[0], "next conversation avoids immediate repetition")
	check(
		not session.beer_errand_started and session.coins == 0,
		"bartender never mutates Lucas quest or coins"
	)
	session.get_node("Daylight").preview_hour = 1
	session.get_node("Daylight")._update_light()
	await capture("dialogue-night")
	session.close_dialogue()
	root.size = Vector2i(844, 390)
	await capture("compact")
	check(await walk_to(Vector3(1.2, 0, -0.5)), "controller steps away from counter stools")
	check(await walk_to(Vector3(1.2, 0, 3.6)), "controller returns along aisle")
	check(await walk_to(Vector3(0, 0, 4.5)), "controller reaches exit")
	await frames(5)
	session.open_map()
	check(
		session.map_ui.is_open and session.map_ui.scandale_button.disabled,
		"exit map marks current bar"
	)
	await capture("compact-map")
	session.map_ui.select(&"lourizan")
	check(await session.travel_to(&"lourizan"), "return to existing Pazo")
	check(
		session.active_guide.speaker_name == "Lucas Maconheiro", "Lucas rebound after leaving bar"
	)
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var previous := -1
	var seen := {}
	for i in 100:
		var chosen := Jokes.choose(previous, rng)
		check(
			chosen != previous and chosen >= 0 and chosen < Jokes.JOKES.size(),
			"valid non-repeating joke"
		)
		seen[chosen] = true
		previous = chosen
	check(seen.size() == Jokes.JOKES.size(), "random selection reaches every joke")
	await frames(2)
	check(
		bartender == null or not is_instance_valid(bartender), "old bartender removed with location"
	)
	print("Scandale: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func walk_to(target: Vector3) -> bool:
	for i in 350:
		var offset := target - player.global_position
		offset.y = 0
		if offset.length() < 0.2:
			release_movement()
			await frames(3)
			return player.is_on_floor()
		await walk_toward(target, 1)
	release_movement()
	push_error("Walk blocked at %s toward %s" % [player.global_position, target])
	return false


func walk_toward(target: Vector3, count: int) -> void:
	for i in count:
		var direction := target - player.global_position
		direction.y = 0
		direction = direction.normalized()
		var camera: Camera3D = session.camera_rig.get_node("Camera")
		var x := direction.dot(Direction.from_view(Vector2.RIGHT, camera.global_basis))
		var y := direction.dot(Direction.from_view(Vector2.UP, camera.global_basis))
		release_movement()
		Input.action_press("move_right" if x > 0 else "move_left", absf(x))
		Input.action_press("move_forward" if y > 0 else "move_back", absf(y))
		await frames(1)
	release_movement()


func release_movement() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)


func frames(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await frames(20)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(
		ProjectSettings.globalize_path("res://../build/verification/scandale/" + label + ".png")
	)


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
