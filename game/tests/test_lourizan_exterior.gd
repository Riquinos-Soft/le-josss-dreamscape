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
	var scan := scene.get_node("CapturedExterior")
	var visuals := scan.find_children("*", "MeshInstance3D", true, false)
	check(visuals.size() == 1, "decimated collision mesh is hidden")
	if visuals.size() == 1:
		check(visuals[0].mesh.get_faces().size() / 3 == 264177, "source triangles retained")
		check(visuals[0].get_active_material(0).albedo_texture != null, "photo texture present")
	await capture("lourizan-start")
	for z in [-10, -8, -6, -4, -2, 0, 2, 4, 6, 4, 2, 0, -2, -4, -6, -8, -10, -12]:
		if not await walk_to(Vector3(6, 0, z)):
			finish()
			return
	check(player.is_on_floor(), "captured path round trip stays grounded")
	finish()


func finish() -> void:
	release_inputs()
	print("Lourizán exterior: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
