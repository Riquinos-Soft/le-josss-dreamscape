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
	var sprite := player.get_node("PixelCharacter") as Sprite3D
	var sheet := sprite.texture.get_image()
	for index in 8:
		var frame_image := sheet.get_region(Rect2i((index % 4) * 64, (index / 4) * 64, 64, 64))
		var bounds := frame_image.get_used_rect()
		check(bounds.size.y == 48 and bounds.end.y == 60, "sprite height and feet pivot consistent")
	for action in ["move_right", "move_forward", "move_left", "move_back"]:
		Input.action_press(action)
		await frames(8)
		var expected: int = {"move_right": 3, "move_forward": 1, "move_left": 2, "move_back": 0}[action]
		check(sprite.frame == expected, "sprite faces " + action)
		Input.action_release(action)
	for entry in [
		["move_left", "move_back", 4],
		["move_right", "move_back", 5],
		["move_left", "move_forward", 6],
		["move_right", "move_forward", 7]
	]:
		player.position = player.spawn_transform.origin
		player.velocity = Vector3.ZERO
		Input.action_press(entry[0])
		Input.action_press(entry[1])
		await frames(8)
		check(sprite.frame == entry[2], "sprite uses true diagonal " + str(entry[2]))
		Input.action_release(entry[0])
		Input.action_release(entry[1])
		await frames(2)
		check(sprite.frame == entry[2], "idle preserves diagonal orientation")
	var orientation := Node3D.new()
	street.add_child(orientation)
	player.movement_orientation = orientation
	for index in range(7, -1, -1):
		await walk_to(street.ROUTE[index])
	await capture("south_end")
	for index in range(1, street.ROUTE.size()):
		await walk_to(street.ROUTE[index])
		if index == 11 and "--capture" in OS.get_cmdline_user_args():
			street.study_material.set_shader_parameter("wall_fade", false)
			for material in street.facade_materials:
				material.set_shader_parameter("wall_fade", false)
			await capture("wall_solid")
			street.study_material.set_shader_parameter("wall_fade", true)
			for material in street.facade_materials:
				material.set_shader_parameter("wall_fade", true)
			await capture("wall_transparent")
		if index == 12:
			for point in street.GARAGE_APPROACH:
				await walk_to(point)
			await capture("garage")
			check(player.is_on_floor(), "garage entrance supports the player")
			for point in range(street.GARAGE_APPROACH.size() - 2, -1, -1):
				await walk_to(street.GARAGE_APPROACH[point])
			await walk_to(street.ROUTE[index])
	await capture("north_end")
	for index in range(street.ROUTE.size() - 2, 6, -1):
		await walk_to(street.ROUTE[index])
	var boundary := PackedVector2Array()
	for index in range(0, street.CROSS_SECTIONS.size(), 2):
		var vertex: Vector3 = street.CROSS_SECTIONS[index]
		boundary.append(Vector2(vertex.x, vertex.z))
	for index in range(street.CROSS_SECTIONS.size() - 1, 0, -2):
		var vertex: Vector3 = street.CROSS_SECTIONS[index]
		boundary.append(Vector2(vertex.x, vertex.z))
	# Push against each variable-width cross section, including the open garage apron.
	for index in range(2, street.CROSS_SECTIONS.size() - 2, 2):
		for side in [-1.0, 1.0]:
			var midpoint: Vector3 = (
				(street.CROSS_SECTIONS[index] + street.CROSS_SECTIONS[index + 1]) * 0.5
			)
			player.global_position = midpoint + Vector3.UP * 0.05
			player.velocity = Vector3.ZERO
			steer(Vector3(side, 0, 0))
			await frames(90)
			steer(Vector3.ZERO)
			check(player.is_on_floor(), "side boundary keeps feet supported at %d" % index)
			check(
				Geometry2D.is_point_in_polygon(
					Vector2(player.position.x, player.position.z), boundary
				),
				"side contains player"
			)
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
