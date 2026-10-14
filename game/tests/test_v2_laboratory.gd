extends SceneTree

var scene: Node3D
var actor: CharacterBody3D
var failures := 0
var checks := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	scene = load("res://v2/validation/laboratory.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	actor = scene.actor
	scene.input_adapter.set_physics_process(false)
	await frames(20)
	check(actor.is_on_floor(), "spawn is grounded")
	actor.set_movement_intent(Vector3(10, 7, 10))
	check(actor.movement_intent.length() <= 1.001, "diagonal intent is bounded")
	check(actor.movement_intent.y == 0, "intent cannot fly")
	actor.set_movement_intent(Vector3(NAN, 0, 0))
	check(actor.movement_intent == Vector3.ZERO, "nonfinite intent stops safely")
	await place(Vector3(-4, 0, -1))
	await move(Vector3.LEFT, 60)
	check(actor.position.x > -5.51 and actor.position.x < -5.45, "west wall blocks capsule")
	await frames(10)
	check(String(scene.presenter.animation).begins_with("idle_"), "blocked motion becomes idle")
	await move(Vector3(-1, 0, -1), 90)
	check(actor.position.x > -5.51 and actor.position.z > -2.51, "corner prevents penetration")
	await place(Vector3(0, 0, -1.8))
	await move(Vector3.FORWARD, 45)
	check(actor.position.z < -4.2, "1.6m doorway permits passage")
	check(actor.position.y < 0.05, "lintel does not lift actor")
	await place(Vector3(0, 0, 0))
	await move(Vector3.RIGHT, 130)
	check(actor.position.x > 4.2, "all five stair risers crossed")
	check(absf(actor.position.y - 1.0) < 0.05, "stair landing reaches one metre")
	await capture("stairs")
	await move(Vector3.LEFT, 90)
	await frames(10)
	check(actor.position.x < 0.5 and absf(actor.position.y) < 0.05, "stairs descend to floor")
	await place(Vector3(4.8, 0, 2))
	await move(Vector3.FORWARD, 45)
	check(
		actor.position.z > 1.3 and actor.position.y < 0.05, "one metre ledge cannot be stepped up"
	)
	await place(Vector3(0, 0, 5))
	await move(Vector3.BACK, 120)
	await frames(30)
	check(actor.position.distance_to(actor.spawn_position) < 0.1, "fall respawns on safe floor")
	var touch := InputEventScreenTouch.new()
	touch.index = 3
	touch.position = Vector2(100, 200)
	touch.pressed = true
	scene.input_adapter.set_physics_process(true)
	scene.input_adapter.handle_touch(touch)
	await frames(2)
	var drag := InputEventScreenDrag.new()
	drag.index = 3
	drag.position = Vector2(200, 200)
	scene.input_adapter.handle_touch(drag)
	await frames(2)
	check(actor.movement_intent.length() > 0.99, "touch adapter provides bounded world intent")
	Input.action_press("move_forward")
	touch.pressed = false
	scene.input_adapter.handle_touch(touch)
	await frames(2)
	check(Input.is_action_pressed("move_forward"), "touch release preserves held keyboard input")
	check(actor.movement_intent.length() > 0.99, "keyboard continues after touch release")
	scene.input_adapter.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(actor.movement_intent == Vector3.ZERO, "focus loss clears motion")
	check(scene.input_adapter.finger == -1, "focus loss releases touch ownership")
	await place(Vector3(-2, 0, 1))
	await capture("desktop")
	root.size = Vector2i(844, 390)
	await frames(5)
	await capture("compact")
	print("V2 laboratory: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func place(at: Vector3) -> void:
	actor.set_movement_intent(Vector3.ZERO)
	actor.position = at + Vector3.UP * 0.02
	actor.velocity = Vector3.ZERO
	actor.reset_physics_interpolation()
	await frames(15)


func move(direction: Vector3, count: int) -> void:
	actor.set_movement_intent(direction)
	await frames(count)
	actor.set_movement_intent(Vector3.ZERO)
	await frames(2)


func frames(count: int) -> void:
	for i in count:
		await physics_frame


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message + " at " + str(actor.position))


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://../build/verification/v2/P2")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))
