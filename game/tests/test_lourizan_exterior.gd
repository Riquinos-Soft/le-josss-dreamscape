extends "res://tests/test_home_exterior.gd"
## Walk the captured paved strip and verify its photographic asset and collision.


func run() -> void:
	scene = load("res://world/locations/lourizan_preview.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	camera = scene.get_node("CameraRig/Camera")
	await frames(45)
	check(player.is_on_floor(), "Lourizán spawn rests on captured paving")
	check(scene.has_node("Architecture"), "authored palace replaces the scan")
	check(not scene.has_node("CapturedExterior"), "raw scan is not rendered or collided")
	check(
		scene.get_node("Architecture").get_child_count() < 180,
		"architecture batches keep node count bounded"
	)
	await capture("lourizan-start")
	var south_crossings := 0
	for z in [-10, -8, -6, -4, -2, 0, 2, 4, 6, 4, 2, 0, -2, -4, -6]:
		if z == -6:
			# The forecourt's south statue has a solid pedestal. Walk around it
			# on the east at the end of the outward and return portions.
			var side_z := -8 if south_crossings == 0 else -4
			if not await walk_to(Vector3(8, 0, side_z) * scene.place_scale):
				finish()
				return
			var exit_z := -4 if south_crossings == 0 else -12
			if not await walk_to(Vector3(8, 0, exit_z) * scene.place_scale):
				finish()
				return
			if south_crossings > 0:
				if not await walk_to(Vector3(6, 0, -12) * scene.place_scale):
					finish()
					return
				break
			south_crossings += 1
		if not await walk_to(Vector3(6, 0, z) * scene.place_scale):
			finish()
			return
	check(player.is_on_floor(), "forecourt round trip stays grounded")
	for point in [
		Vector3(7, 0, -12),
		Vector3(7, 0, 9),
		Vector3(5.6, 0, 9),
		Vector3(3.5, 0, 9),
		Vector3(0.5, 0, 9)
	]:
		if not await walk_to(point * scene.place_scale):
			finish()
			return
	check(player.position.y > 3.5 * scene.place_scale, "stairs reach the raised terrace")
	await capture("lourizan-terrace")
	for point in [Vector3(3.5, 0, 9), Vector3(6.5, 0, 9)]:
		if not await walk_to(point * scene.place_scale):
			finish()
			return
	check(player.position.y < 0.5, "first stair returns to the forecourt")
	for point in [
		Vector3(7, 0, 9),
		Vector3(7, 0, -9),
		Vector3(5.6, 0, -9),
		Vector3(3.5, 0, -9),
		Vector3(0.5, 0, -9)
	]:
		if not await walk_to(point * scene.place_scale):
			finish()
			return
	check(player.position.y > 3.5 * scene.place_scale, "second stair reaches the raised terrace")
	for point in [Vector3(3.5, 0, -9), Vector3(6.5, 0, -9)]:
		if not await walk_to(point * scene.place_scale):
			finish()
			return
	check(player.position.y < 0.5, "second stair returns to the forecourt")
	finish()


func finish() -> void:
	release_inputs()
	print("Lourizán exterior: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
