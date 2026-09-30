extends "res://tests/test_home_exterior.gd"
## Uses the existing input-driven walk helper to verify two real stair flights.


func run() -> void:
	scene = load("res://tests/fixtures/three_floor_stairs.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	camera = scene.get_node("CameraRig/Camera")
	await frames(30)
	check(player.is_on_floor(), "upper landing supports spawn")
	await capture("04-stair-module")
	for point in [
		Vector3(0, 2.8, -6.6), Vector3(0, 0, 1), Vector3(0, 2.8, -6.6), Vector3(0, 5.6, -14.2)
	]:
		if not await walk_to(point):
			finish()
			return
		check(player.is_on_floor(), "landing remains grounded: %s" % point)
		check(absf(player.position.y - point.y) < 0.08, "correct floor: %s" % point)
	# Approach the middle of a flight, then attempt to walk through the side rail.
	if not await walk_to(Vector3(0, 4.2, -10.4)):
		finish()
		return
	var right := Direction.from_view(Vector2.RIGHT, camera.global_basis)
	var forward := Direction.from_view(Vector2.UP, camera.global_basis)
	Input.action_press("move_right", Vector3.RIGHT.dot(right))
	Input.action_press("move_back", -Vector3.RIGHT.dot(forward))
	await frames(60)
	release_inputs()
	check(player.position.x < 0.45, "rail prevents leaving flight sideways")
	check(player.is_on_floor(), "rail contact remains supported")
	finish()


func finish() -> void:
	release_inputs()
	print("Connected stairs: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
