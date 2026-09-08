extends SceneTree
## Exercises our actual scene wiring, inputs, and collision layout, not a physics reimplementation.

var failures: int = 0
var checks: int = 0
var player: CharacterBody3D
var camera: Camera3D


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var courtyard := load("res://world/courtyard.tscn").instantiate() as Node3D
	root.add_child(courtyard)
	current_scene = courtyard
	player = courtyard.get_node("Player")
	camera = courtyard.get_node("CameraRig/Camera")
	await frames(15)
	check(player.is_on_floor(), "spawn grounded")
	var start := player.position
	Input.action_press("move_forward")
	await frames(30)
	Input.action_release("move_forward")
	await frames(2)
	var displacement := player.position - start
	check(
		displacement.length() > 1.8 and displacement.length() < 2.2,
		"4 m/s movement over half a second"
	)
	check(displacement.x < -0.5 and displacement.z < -0.5, "W follows diagonal camera heading")
	var stopped := player.position
	await frames(10)
	check(player.position.distance_to(stopped) < 0.01, "clean input release")
	# Isolate layout checks from view orientation. The controller accepts another
	# orientation node.
	var orientation := Node3D.new()
	courtyard.add_child(orientation)
	player.movement_orientation = orientation
	for entry in [
		[Vector3(0, 0.02, 5), "move_left", 180, "WestWall"],
		[Vector3(0, 0.02, 5), "move_right", 180, "EastWall"],
		[Vector3(0, 0.02, 0), "move_forward", 150, "NorthWall"],
		# Keep this wall route clear of the authored physical item at (0, 1.5).
		[Vector3(-6, 0.02, 0), "move_back", 150, "SouthWall"],
		[Vector3(-3, 0.02, 1), "move_forward", 60, "WideObstacle"],
		[Vector3(0, 0.02, 0), "move_right", 60, "LongObstacle"],
	]:
		player.position = entry[0]
		player.velocity = Vector3.ZERO
		player.reset_physics_interpolation()
		await frames(5)
		Input.action_press(entry[1])
		await frames(entry[2])
		var hit_expected := false
		for index in player.get_slide_collision_count():
			if player.get_slide_collision(index).get_collider().name == entry[3]:
				hit_expected = true
		check(hit_expected, "collision with " + entry[3])
		check(
			absf(player.position.x) < 10 and absf(player.position.z) < 8,
			"inside bounds at " + entry[3]
		)
		check(player.is_on_floor() and absf(player.position.y) < 0.05, "grounded at " + entry[3])
		Input.action_release(entry[1])
		await frames(2)
		check(not camera.is_position_behind(player.position + Vector3.UP), "camera faces player")
	# Exercise focus handling at the input boundary without depending on OS automation.
	Input.action_press("move_forward")
	player.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	stopped = player.position
	await frames(5)
	check(player.position.distance_to(stopped) < 0.01, "focus loss stops movement")
	player.notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	Input.action_press("move_forward")
	await frames(5)
	check(player.position.distance_to(stopped) > 0.2, "input works after focus return")
	Input.action_release("move_forward")
	print("Courtyard integration: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	# Read after the last physics tick, not before the controller has run.
	await process_frame


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
