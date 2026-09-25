extends SceneTree

var failures := 0
var checks := 0
var controls: Control


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	await check_scene("res://world/courtyard.tscn")
	await check_scene("res://world/jacobo_risa_street.tscn")
	print("Touch controls: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func check_scene(scene_path: String) -> void:
	var scene = load(scene_path).instantiate()
	root.add_child(scene)
	current_scene = scene
	controls = scene.get_node("TouchHUD/TouchControls")
	# Enable through the same ready path as a touchscreen, even in headless CI.
	if not controls.enabled:
		controls.enable_touch()
	await frames(10)
	var player = scene.get_node("Player")
	var items = scene.get_node("ItemLoop")
	var original = items.world_item.item
	var original_position: Vector3 = items.world_item.position
	await check_pickup_availability(scene, player, items)
	if scene_path.ends_with("jacobo_risa_street.tscn"):
		original_position = items.supported_pose(Vector3(2.25, 0, 1.1), PI / 2)
	tap_action("pickup")
	await frames(2)
	check(items.inventory.item == original, "touch pickup preserves identity")
	check(controls.action_rects.keys() == ["begin"], "held item exposes only placement")
	tap_action("begin")
	await frames(2)
	check(items.placement_active, "touch starts placement")
	check(
		controls.action_rects.keys() == ["right", "confirm"],
		"only rotate and confirm while placing"
	)
	check(
		items.target.is_equal_approx(items.initial_placement_target()), "preview defaults in front"
	)
	var mouse := InputEventMouseButton.new()
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	root.push_input(mouse, true)
	Input.flush_buffered_events()
	await frames(2)
	check(items.placement_active, "emulated mouse cannot confirm placement")
	tap_action("confirm")
	await frames(2)
	check(
		(
			not items.placement_active
			and is_instance_valid(items.world_item)
			and items.world_item.item == original
		),
		"default front placement confirms without dragging"
	)
	tap_action("pickup")
	await frames(2)
	tap_action("begin")
	await frames(2)
	touch(0, controls.stick_center + Vector2(100, 0), true)
	var start: Vector3 = player.position
	await frames(5)
	check(player.position.distance_to(start) > 0.1, "joystick moves actual player during placement")
	check(
		items.target.distance_to(items.initial_placement_target()) < 0.08,
		"preview follows in front until dragged"
	)
	tap_action("right")
	await frames(2)
	check(is_equal_approx(items.yaw, PI / 2), "second finger rotates")
	check(player.touch_direction.x > 0.8, "action finger does not release movement")
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = controls.stick_center + Vector2(-500, 0)
	root.push_input(drag, true)
	Input.flush_buffered_events()
	check(player.touch_direction == Vector2.LEFT, "drag outside pad stays owned and clamped")
	touch(0, Vector2.ZERO, false)
	await frames(2)
	check(player.touch_direction == Vector2.ZERO, "release outside joystick stops movement")
	for turn in 3:
		tap_action("right")
		await frames(1)
	check(is_zero_approx(items.yaw), "one rotate button reaches all four orientations")
	tap_action("right")
	await frames(1)
	var aim: Vector2 = scene.get_node("CameraRig/Camera").unproject_position(
		original_position - Vector3.UP * 0.25
	)
	touch(2, aim, true)
	touch(2, aim, false)
	await frames(2)
	check(not items.touch_aim_set, "a floor tap does not move the preview")
	aim = items.camera.unproject_position(original_position - Vector3.UP * 0.25)
	var preview_point: Vector2 = items.camera.unproject_position(items.preview.global_position)
	touch(2, preview_point, true)
	drag.index = 2
	drag.position = aim
	root.push_input(drag, true)
	Input.flush_buffered_events()
	touch(2, aim, false)
	await frames(2)
	check(items.touch_aim_set, "dragging the preview aims")
	check(
		items.target.distance_to(original_position) < 0.05,
		"touch ray reaches floor: %s expected %s" % [items.target, original_position]
	)
	var dragged_target: Vector3 = items.target
	touch(0, controls.stick_center + Vector2(100, 0), true)
	await frames(2)
	touch(0, Vector2.ZERO, false)
	check(items.target == dragged_target, "released preview stays at its world position")
	# With no Cancel button, an invalid drag must remain visible and recoverable.
	var confirm_point: Vector2 = controls.action_rects["confirm"].get_center()
	drag_preview(items, Vector2(440, 100))
	await frames(2)
	check(items.target.x != 1000 and not items.target_valid, "invalid preview stays visible")
	check(controls.action_rects.keys() == ["right"], "invalid placement hides confirm")
	touch(1, confirm_point, true)
	touch(1, confirm_point, false)
	await frames(2)
	check(
		items.placement_active and items.inventory.item == original, "invalid confirm retains item"
	)
	drag_preview(items, items.camera.unproject_position(original_position - Vector3.UP * 0.25))
	await frames(2)
	check(items.target_valid, "invalid placement can be dragged back to valid ground")
	check(controls.action_rects.has("confirm"), "valid placement restores confirm")
	tap_action("confirm")
	await frames(2)
	check(
		(
			not items.placement_active
			and is_instance_valid(items.world_item)
			and items.world_item.item == original
		),
		"touch confirms same item"
	)
	tap_action("pickup")
	await frames(2)
	tap_action("begin")
	await frames(2)
	check(
		items.placement_active and items.inventory.item == original,
		"next placement retains item until confirm"
	)
	touch(0, controls.stick_center + Vector2(100, 0), true)
	controls.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(player.touch_direction == Vector2.ZERO, "focus loss clears joystick")
	touch(0, controls.stick_center + Vector2(100, 0), true)
	var cancel := InputEventScreenTouch.new()
	cancel.index = 0
	cancel.canceled = true
	root.push_input(cancel, true)
	Input.flush_buffered_events()
	check(player.touch_direction == Vector2.ZERO, "cancelled touch clears joystick")
	root.size = Vector2i(720, 1280)
	await process_frame
	controls.update_layout()
	check(paused and controls.portrait, "portrait pauses simulation")
	var before: Vector3 = player.position
	touch(0, controls.stick_center + Vector2(100, 0), true)
	await frames(3)
	check(
		player.position == before and player.touch_direction == Vector2.ZERO,
		"portrait ignores touches"
	)
	root.size = Vector2i(1280, 720)
	await process_frame
	controls.update_layout()
	check(not paused and not controls.portrait, "landscape resumes")
	check(player.touch_direction == Vector2.ZERO, "rotation cannot leave movement stuck")
	scene.queue_free()
	await process_frame


func check_pickup_availability(scene: Node, player: Node3D, items: Node) -> void:
	check(controls.action_rects.keys() == ["pickup"], "reachable item exposes pickup")
	var pickup_point: Vector2 = controls.action_rects["pickup"].get_center()
	var start := player.global_position
	player.global_position += Vector3(0, 0, 5)
	await frames(2)
	check(controls.action_rects.is_empty(), "no actions when item is too far away")
	check(controls.message.text.is_empty(), "no pickup instruction when unavailable")
	touch(1, pickup_point, true)
	touch(1, pickup_point, false)
	await frames(2)
	check(items.inventory.item == null, "hidden pickup area does nothing")
	player.global_position = start
	player.velocity = Vector3.ZERO
	await frames(5)
	check(controls.action_rects.has("pickup"), "approaching restores pickup")
	var barrier := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.4, 0.6, 0.4)
	collision.shape = shape
	barrier.add_child(collision)
	scene.add_child(barrier)
	barrier.global_position = (player.global_position + items.world_item.global_position) * 0.5
	barrier.global_position.y += 0.2
	await frames(3)
	check(not controls.action_rects.has("pickup"), "obstacle blocks pickup action")
	barrier.queue_free()
	await frames(3)
	check(controls.action_rects.has("pickup"), "clear path restores pickup")


func touch(index: int, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	root.push_input(event, true)
	Input.flush_buffered_events()


func tap_action(action: String) -> void:
	var point: Vector2 = controls.action_rects[action].get_center()
	touch(1, point, true)
	touch(1, point, false)


func drag_preview(items: Node, point: Vector2) -> void:
	touch(2, items.camera.unproject_position(items.preview.global_position), true)
	var event := InputEventScreenDrag.new()
	event.index = 2
	event.position = point
	root.push_input(event, true)
	Input.flush_buffered_events()
	touch(2, point, false)


func frames(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
