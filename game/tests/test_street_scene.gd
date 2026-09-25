extends SceneTree
## Confirms the imported scan is a walkable, bounded geometry trial.

var checks: int = 0
var failures: int = 0
var player: CharacterBody3D


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var street := load("res://world/jacobo_risa_street.tscn").instantiate() as Node3D
	root.add_child(street)
	current_scene = street
	var visual: MeshInstance3D = street.first_mesh(street.get_node("StreetVisual"))
	check(visual != null, "scan mesh loaded")
	if visual == null:
		quit(1)
		return
	check(visual.mesh.surface_get_array_index_len(0) / 3 <= 50000, "scan within triangle budget")
	var collision := street.get_node("StreetCollision/Collision") as CollisionShape3D
	check(collision.shape is ConcavePolygonShape3D, "authored continuous floor generated")
	player = street.get_node("Player") as CharacterBody3D
	await frames(120)
	check(player.is_on_floor(), "player settles on scanned street")
	check(player.global_position.y > 0.2, "player stays on street surface")
	await capture("spawn")
	var orientation := Node3D.new()
	street.add_child(orientation)
	player.movement_orientation = orientation
	for index in range(7, -1, -1):
		await walk_to(street.ROUTE[index])
	await capture("south_end")
	for index in range(1, street.ROUTE.size()):
		await walk_to(street.ROUTE[index])
	await capture("north_end")
	for index in range(street.ROUTE.size() - 2, 6, -1):
		await walk_to(street.ROUTE[index])
	# At every join, push toward both boundaries using the real controller.
	for index in range(1, street.ROUTE.size() - 1):
		for side in [-1.0, 1.0]:
			player.global_position = street.ROUTE[index] + Vector3.UP * 0.05
			player.velocity = Vector3.ZERO
			steer(Vector3(side, 0, 0))
			await frames(90)
			steer(Vector3.ZERO)
			check(player.is_on_floor(), "side boundary keeps feet supported at %d" % index)
			var distance := INF
			for segment in street.ROUTE.size() - 1:
				var a: Vector3 = street.ROUTE[segment]
				var b: Vector3 = street.ROUTE[segment + 1]
				var closest := Geometry2D.get_closest_point_to_segment(
					Vector2(player.position.x, player.position.z),
					Vector2(a.x, a.z),
					Vector2(b.x, b.z)
				)
				distance = minf(
					distance, closest.distance_to(Vector2(player.position.x, player.position.z))
				)
			check(distance < street.HALF_WIDTH, "side contains player")
	for index in [0, street.ROUTE.size() - 1]:
		var inward: Vector3 = (
			(street.ROUTE[1] - street.ROUTE[0]).normalized()
			if index == 0
			else (street.ROUTE[-2] - street.ROUTE[-1]).normalized()
		)
		player.position = street.ROUTE[index] + inward * 0.7 + Vector3.UP * 0.05
		player.velocity = Vector3.ZERO
		steer(Vector3(0, 0, -1 if index == 0 else 1))
		await frames(90)
		steer(Vector3.ZERO)
		check(player.position.distance_to(street.ROUTE[index]) < 0.6, "end cap contains player")
	for attempt in 2:
		player.position = Vector3(20, -12, 20)
		player.velocity = Vector3(5, -40, 8)
		await frames(1)
		check(player.global_transform == player.spawn_transform, "fall restores original spawn")
		check(player.velocity == Vector3.ZERO, "fall clears momentum")
		var camera := street.get_node("CameraRig") as Node3D
		check(
			camera.position.distance_to(player.position + Vector3.UP * 0.9) < 0.01,
			"fall snaps camera to spawn"
		)
	await frames(30)
	print(
		(
			"Street trial: %d checks, %d failures; player at %s"
			% [checks, failures, player.global_position]
		)
	)
	quit(0 if failures == 0 else 1)


func steer(direction: Vector3) -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)
	if direction.x < 0:
		Input.action_press("move_left", -direction.x)
	if direction.x > 0:
		Input.action_press("move_right", direction.x)
	if direction.z < 0:
		Input.action_press("move_forward", -direction.z)
	if direction.z > 0:
		Input.action_press("move_back", direction.z)


func capture(label: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args():
		return
	await frames(40)
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("res://../build/verification/street_%s.png" % label)
	root.get_texture().get_image().save_png(path)


func walk_to(target: Vector3) -> void:
	var reached := false
	for tick in 240:
		var offset := target - player.global_position
		offset.y = 0
		if offset.length() < 0.42:
			reached = true
			break
		steer(offset.normalized())
		await frames(1)
	steer(Vector3.ZERO)
	check(reached, "walk reaches %s (actual %s)" % [target, player.position])
	check(player.position.y >= target.y - 0.25, "route remains supported")


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
