extends SceneTree

const Route = preload("res://v2/validation/collision_route.gd")


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var scene = load("res://v2/validation/laboratory.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	# Starting verification during a fall must not report a false spawn failure.
	scene.actor.position.y = -6.0
	var result: Dictionary = await Route.new().run(scene, capture)
	await capture("desktop")
	root.size = Vector2i(844, 390)
	for i in 5:
		await physics_frame
	await capture("compact")
	print("V2 laboratory: %d checks, %d failures" % [result.checks, result.failures])
	quit(1 if result.failures else 0)


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://../build/verification/v2/P2")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))
