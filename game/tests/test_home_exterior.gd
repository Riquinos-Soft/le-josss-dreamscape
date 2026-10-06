extends SceneTree
## Tests the imported capture and walks its existing western path via player input.

const Direction = preload("res://player/movement_direction.gd")
var scene: Node3D
var player: CharacterBody3D
var camera: Camera3D
var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	scene = load("res://world/home_exterior.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	camera = scene.get_node("CameraRig/Camera")
	await frames(45)
	check(player.is_on_floor(), "spawn rests on captured ground")
	check(
		player.position.y > 4.3 * scene.place_scale and player.position.y < 5.0 * scene.place_scale,
		"scaled terrain elevation"
	)
	var scan := scene.get_node("CapturedExterior")
	var bodies := scan.find_children("*", "StaticBody3D", true, false)
	check(bodies.size() == 1, "imported static scan collision")
	var visuals := scan.find_children("*", "MeshInstance3D", true, false)
	check(visuals.size() == 1, "collision mesh not rendered")
	if visuals.size() == 1:
		check(
			visuals[0].mesh.get_faces().size() / 3 == 249260,
			"all captured visual triangles retained"
		)
		var material = visuals[0].get_active_material(0)
		check(material.albedo_texture != null, "photographic texture is present")
		check(
			material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED,
			"capture lighting retained"
		)
	print("Spawn: ", player.position, " camera: ", camera.global_position)
	await capture("01-home-exterior")
	for z in [10, 8, 6, 4, 2, 0, -2, -4, -6, -8]:
		if not await walk_to(Vector3(8, 0, z) * scene.place_scale):
			finish()
			return
	await capture("02-garden-path")
	for z in [-6, -4, -2, 0, 2, 4, 6, 8, 10, 12]:
		if not await walk_to(Vector3(8, 0, z) * scene.place_scale):
			finish()
			return
	check(player.is_on_floor(), "round trip remains grounded")
	var screen_point := camera.unproject_position(player.position + Vector3.FORWARD * 2)
	var direction: Vector3 = player.mouse_movement_direction(screen_point)
	check(direction.normalized().dot(Vector3.FORWARD) > 0.99, "mouse target uses current elevation")
	Input.action_press("move_forward")
	player.mouse_steering_active = true
	player.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(
		not player.mouse_steering_active and not Input.is_action_pressed("move_forward"),
		"focus clears steering"
	)
	await capture("03-return")
	finish()


func walk_to(point: Vector3) -> bool:
	for index in 400:
		var offset := point - player.position
		offset.y = 0
		if offset.length() < 0.16:
			release_inputs()
			await frames(5)
			check(player.position.y > -1.5, "walk on scan to %s" % point)
			return true
		var direction := offset.normalized() * minf(1, offset.length() * 5)
		var right := Direction.from_view(Vector2.RIGHT, camera.global_basis)
		var forward := Direction.from_view(Vector2.UP, camera.global_basis)
		var x := direction.dot(right)
		var y := direction.dot(forward)
		release_inputs()
		Input.action_press("move_right" if x > 0 else "move_left", absf(x))
		Input.action_press("move_forward" if y > 0 else "move_back", absf(y))
		await frames(1)
	release_inputs()
	print(
		"BLOCK_DIAGNOSTIC grounded=",
		player.is_on_floor(),
		" support=",
		player.has_ground_ahead((point - player.position).normalized()),
		" velocity=",
		player.velocity
	)
	for i in player.get_slide_collision_count():
		print(
			"COLLISION ",
			player.get_slide_collision(i).get_normal(),
			" at ",
			player.get_slide_collision(i).get_position()
		)
	check(false, "path blocked at %s while approaching %s" % [player.position, point])
	return false


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless" or "--capture" not in OS.get_cmdline_user_args():
		return
	await frames(25)
	RenderingServer.force_draw(false)
	var folder := ProjectSettings.globalize_path("res://../build/verification/home-scan")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func release_inputs() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)


func finish() -> void:
	release_inputs()
	print("Captured exterior: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
