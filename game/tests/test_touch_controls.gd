extends SceneTree

var failures := 0
var checks := 0
var controls: Control


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var scene = load("res://world/courtyard.tscn").instantiate()
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
	tap_action("pickup")
	await frames(2)
	check(items.inventory.item == original, "touch pickup preserves identity")
	tap_action("begin")
	await frames(2)
	check(items.placement_active, "touch starts placement")
	var mouse := InputEventMouseButton.new()
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	root.push_input(mouse, true)
	Input.flush_buffered_events()
	await frames(2)
	check(items.placement_active, "emulated mouse cannot confirm placement")
	touch(0, controls.stick_center + Vector2(100, 0), true)
	var start: Vector3 = player.position
	await frames(5)
	check(player.position.distance_to(start) > 0.1, "joystick moves actual player during placement")
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
	var aim: Vector2 = scene.get_node("CameraRig/Camera").unproject_position(Vector3(0, 0, 1.5))
	touch(2, aim, true)
	touch(2, aim, false)
	await frames(2)
	check(items.touch_aim_set, "world touch aims")
	check(items.target.distance_to(Vector3(0, 0.25, 1.5)) < 0.05, "touch ray reaches floor")
	tap_action("confirm")
	await frames(2)
	check(
		not items.placement_active and items.world_item.item == original, "touch confirms same item"
	)
	tap_action("pickup")
	await frames(2)
	tap_action("begin")
	await frames(2)
	tap_action("cancel")
	await frames(2)
	check(not items.placement_active and items.inventory.item == original, "cancel retains item")
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
	print("Touch controls: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


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


func frames(count: int) -> void:
	for i in count:
		await physics_frame


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
