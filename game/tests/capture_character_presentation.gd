extends SceneTree
## Native A/B captures at identical poses, plus a short continuous walk sequence.


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(0)
		return
	var session: Node3D = load("res://world/dreamscape.tscn").instantiate()
	root.add_child(session)
	current_scene = session
	await frames(25)
	var player: CharacterBody3D = session.player
	player.global_position = session.street.get_node("Exit").global_position + Vector3.UP * 0.25
	player.reset_physics_interpolation()
	await frames(6)
	session.open_map()
	session.map_ui.select(&"lourizan")
	if not await session.travel_to(&"lourizan"):
		push_error("Capture could not load Lourizán")
		quit(1)
		return
	var guide: Node3D = session.active_guide
	guide.set_conversation_active(true)
	player.global_position = guide.global_position + Vector3(1.6, 0, 0)
	player.reset_physics_interpolation()
	var character: AnimatedSprite3D = player.get_node("PixelCharacter")
	character.facing = &"down"
	session.camera_rig.snap_to_target()
	await frames(30)
	var material: ShaderMaterial = session.street.get_node("PixelPass/Screen").material
	for dimensions in [Vector2i(1280, 720), Vector2i(844, 390)]:
		root.size = dimensions
		if dimensions.y < 400:
			session.touch_controls.enable_touch()
		await frames(10)
		for legacy in [true, false]:
			material.set_shader_parameter("world_pixel_height", 180.0 if legacy else 0.0)
			character.texture_filter = (
				BaseMaterial3D.TEXTURE_FILTER_NEAREST
				if legacy
				else BaseMaterial3D.TEXTURE_FILTER_LINEAR
			)
			await capture(("before" if legacy else "after") + "-%d" % dimensions.y)
	root.size = Vector2i(1280, 720)
	Input.action_press("move_right")
	for index in 12:
		await frames(4)
		await capture("walk-%02d" % index)
	Input.action_release("move_right")
	print("Character presentation: captured desktop, compact and walk sequence")
	quit(0)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	await process_frame
	RenderingServer.force_draw(false)
	var folder := ProjectSettings.globalize_path("res://../build/verification/restyle")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))
