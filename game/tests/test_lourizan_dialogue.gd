extends SceneTree
## Integrated guide, paged dialogue, input lock and travel lifecycle.

var checks := 0
var failures := 0
var session: Node3D
var player: CharacterBody3D
var dialogue: CanvasLayer


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	session = load("res://world/dreamscape.tscn").instantiate()
	root.add_child(session)
	current_scene = session
	player = session.get_node("Street/Player")
	dialogue = session.get_node("DialogueBubble")
	await frames(20)
	await travel_from_street(&"lourizan")
	check(session.current_id == &"lourizan", "arrives in Lourizán")
	check(session.active_location.get_children().filter(is_guide).size() == 1, "one guide exists")
	var guide: Node3D = session.active_location.get_node("LucasMaconheiro")
	check(guide.name == "LucasMaconheiro", "guide has stable scene identity")
	check(guide is AnimatableBody3D, "walking guide uses a movable physics body")
	var guide_sprite: AnimatedSprite3D = guide.get_node("Sprite")
	var directional_animations := true
	for direction in [
		"down", "up", "left", "right", "down_left", "down_right", "up_left", "up_right"
	]:
		directional_animations = (
			directional_animations
			and guide_sprite.sprite_frames.has_animation("idle_" + direction)
			and guide_sprite.sprite_frames.has_animation("walk_" + direction)
		)
	check(directional_animations, "Lucas has eight-direction idle and walk art")
	var patrol_start := guide.global_position
	await frames(80)
	check(
		guide.global_position.distance_to(patrol_start) > 0.4,
		"Lucas leaves his starting point on foot"
	)
	check(guide_sprite.animation.begins_with("walk_"), "patrol plays a walk animation")
	check(guide.is_inside_patrol_bounds(), "Lucas remains inside the safe garden route")
	await capture("lucas-walking")
	guide.walk_speed = 8.0
	var patrol_wait_frames := 0
	while guide.reached_waypoints == 0 and patrol_wait_frames < 90:
		await physics_frame
		patrol_wait_frames += 1
	check(guide.reached_waypoints > 0, "Lucas reaches an authored garden waypoint")
	check(guide.pause_remaining > 0.0, "Lucas pauses at a garden waypoint")
	guide.walk_speed = 0.8
	check(not session.can_open_dialogue(), "arrival outside range cannot start conversation")
	player.global_position = guide.global_position + Vector3(1.25, 0.05, 0)
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	await frames(5)
	check(session.can_open_dialogue(), "nearby guide can be addressed")
	check(guide.talk_marker.visible, "talk marker appears above Lucas")

	var barrier := StaticBody3D.new()
	barrier.collision_layer = 1
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.3, 1.8, 0.8)
	collision.shape = shape
	barrier.add_child(collision)
	session.active_location.add_child(barrier)
	barrier.global_position = (
		(player.global_position + guide.global_position) / 2 + Vector3.UP * 0.8
	)
	await frames(3)
	check(not session.can_open_dialogue(), "wall blocks conversation")
	barrier.queue_free()
	await frames(3)
	check(session.can_open_dialogue(), "clear line restores conversation")
	await capture("lucas-approach")

	key(KEY_E)
	await frames(2)
	check(dialogue.is_open and dialogue.page_index == 0, "opening input shows page one")
	check(player.input_locked, "dialogue locks movement")
	check(guide.conversation_active, "dialogue pauses Lucas patrol")
	var guide_talk_position := guide.global_position
	await frames(30)
	check(
		guide.global_position.distance_to(guide_talk_position) < 0.001,
		"Lucas stays still throughout dialogue"
	)
	check(guide_sprite.animation.begins_with("idle_"), "talking Lucas uses his idle pose")
	check(
		not session.get_node("Street/TouchHUD/TouchControls").input_enabled,
		"dialogue releases touch to UI"
	)
	check(dialogue.body_label.text.begins_with("Bienvenido"), "first sourced paragraph is shown")
	check(not session.get_node("TravelMap").guide.visible, "map guide hides during conversation")
	var locked_position := player.global_position
	Input.action_press("move_forward")
	await frames(5)
	Input.action_release("move_forward")
	var horizontal_shift := (
		Vector2(
			player.global_position.x - locked_position.x,
			player.global_position.z - locked_position.z
		)
		. length()
	)
	check(horizontal_shift < 0.01, "movement stays locked")
	session.open_map()
	check(not session.get_node("TravelMap").is_open, "map cannot open over dialogue")

	var repeated := InputEventKey.new()
	repeated.physical_keycode = KEY_E
	repeated.pressed = true
	repeated.echo = true
	root.push_input(repeated, true)
	Input.flush_buffered_events()
	await frames(1)
	check(dialogue.page_index == 0, "held key cannot skip a page")
	key(KEY_E)
	await frames(1)
	check(dialogue.page_index == 1, "fresh action advances once")
	root.size = Vector2i(844, 390)
	await frames(2)
	var rect: Rect2 = dialogue.panel.get_global_rect()
	var logical_size: Vector2 = dialogue.get_viewport().get_visible_rect().size
	check(
		rect.position.x >= 0 and rect.end.x <= logical_size.x,
		"compact bubble stays horizontally visible: %s" % rect
	)
	check(
		rect.position.y >= 0 and rect.end.y <= logical_size.y,
		"compact bubble stays vertically visible"
	)
	check(
		dialogue.body_label.get_theme_font_size("font_size") == 16,
		"compact window uses readable compact typography"
	)
	root.size = Vector2i(1280, 720)
	await frames(2)
	await capture("lucas-dialogue")
	key(KEY_ENTER)
	await frames(1)
	check(dialogue.page_index == 2, "enter advances dialogue")
	key(KEY_SPACE)
	await frames(1)
	check(
		dialogue.page_index == 3 and dialogue.continue_button.text == "Terminar",
		"last page is explicit"
	)
	key(KEY_E)
	await frames(2)
	check(not dialogue.is_open and not player.input_locked, "final action restores movement")
	check(session.get_node("Street/TouchHUD/TouchControls").input_enabled, "touch movement returns")
	check(not guide.conversation_active, "closing dialogue releases Lucas patrol")
	var guide_resume_position := guide.global_position
	await frames(75)
	check(
		guide.global_position.distance_to(guide_resume_position) > 0.2,
		"Lucas resumes from the same patrol after dialogue"
	)

	session.open_dialogue()
	await frames(1)
	check(dialogue.page_index == 0, "reopening starts at page one")
	dialogue.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await frames(1)
	check(not dialogue.is_open and not player.input_locked, "focus loss closes safely")
	var touch_controls: Control = session.get_node("Street/TouchHUD/TouchControls")
	touch_controls.enable_touch()
	await frames(2)
	check(touch_controls.action_rects.has("talk"), "touch talk action appears near Lucas")
	var tap := InputEventScreenTouch.new()
	tap.index = 7
	tap.position = touch_controls.action_rects["talk"].get_center()
	tap.pressed = true
	root.push_input(tap, true)
	Input.flush_buffered_events()
	await frames(2)
	check(dialogue.is_open and dialogue.page_index == 0, "touch opens dialogue at page one")
	dialogue.close()
	await frames(2)
	check(touch_controls.input_enabled, "closing touch dialogue restores controls")

	await enter_exit(session.active_location.get_node("Exit"))
	session.open_map()
	session.get_node("TravelMap").select(&"street")
	check(await session.travel_to(&"street"), "leaves Lourizán")
	await frames(8)
	await travel_from_street(&"lourizan")
	check(
		session.active_location.get_children().filter(is_guide).size() == 1,
		"return creates one guide"
	)
	check(not dialogue.is_open and dialogue.page_index == 0, "return has no stale balloon")
	finish()


func travel_from_street(destination: StringName) -> void:
	await enter_exit(session.get_node("Street/Exit"))
	session.open_map()
	session.get_node("TravelMap").select(destination)
	check(await session.travel_to(destination), "travel succeeds")
	await frames(8)


func enter_exit(exit: Area3D) -> void:
	player.global_position = exit.global_position + Vector3.UP * 0.25
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	await frames(5)


func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event, true)
	Input.flush_buffered_events()


func is_guide(node: Node) -> bool:
	return node.is_in_group("lourizan_guide")


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless" or "--capture" not in OS.get_cmdline_user_args():
		return
	await frames(20)
	RenderingServer.force_draw(false)
	var folder := ProjectSettings.globalize_path("res://../build/verification/lucas-patrol")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)


func finish() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)
	print("Lourizán dialogue: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
