extends SceneTree
## Account-only perspective: reversible state, real input, collision and Pazo views.

const Catalog = preload("res://v2/characters/appearance_catalog.gd")
const Direction = preload("res://player/directional_animation.gd")
var scene: Node3D
var mode: Node3D
var failures := 0
var checks := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	scene = load("res://v2/account/session.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	scene.get_node("Daylight").preview_hour = 13.0
	scene.handle_packet(
		{
			"type": "welcome",
			"character":
			{
				"appearance": Catalog.preset(),
				"place": "lourizan",
				"position": [9.6, .05, 0],
				"saved_at": "fixture"
			}
		}
	)
	mode = scene.camera_mode
	scene.input_adapter.set_physics_process(false)
	scene.actor.set_physics_process(true)
	scene.presenter.set_physics_process(true)
	await frames(30)
	var original: Camera3D = scene.camera
	var original_frames: SpriteFrames = scene.presenter.sprite_frames
	check(
		not mode.enabled and original.projection == Camera3D.PROJECTION_ORTHOGONAL,
		"orthographic remains default"
	)
	check(scene.actor.is_on_floor(), "existing Lourizan arrival is grounded")
	await capture("arrival-orthographic")
	key(KEY_C)
	await frames(8)
	check(mode.enabled and scene.camera == mode.perspective, "C activates perspective")
	check(scene.camera == root.get_camera_3d(), "active viewport uses perspective camera")
	check(scene.input_adapter.camera == scene.camera, "input uses active camera")
	check(scene.presenter.movement_view == scene.camera, "presenter uses active camera")
	check(scene.presenter.sprite_frames == original_frames, "original sprites reused unchanged")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "cursor never captured")
	# Camera-only drag changes neither the actor nor its network-intent format.
	var position: Vector3 = scene.actor.position
	var heading: float = mode.target_yaw
	mouse(MOUSE_BUTTON_RIGHT, true)
	motion(Vector2(100, -60))
	await frames(15)
	check(not is_equal_approx(mode.target_yaw, heading), "right drag orbits")
	check(scene.actor.position.distance_to(position) < .01, "orbit cannot steer the actor")
	check(scene.actor.movement_intent == Vector3.ZERO, "orbit does not generate movement")
	mouse(MOUSE_BUTTON_RIGHT, false)
	heading = mode.target_yaw
	motion(Vector2(100, 0))
	check(is_equal_approx(mode.target_yaw, heading), "released drag stops orbit")
	for index in 60:
		mouse(MOUSE_BUTTON_WHEEL_UP, true)
	check(mode.distance == mode.MIN_DISTANCE, "zoom-in bounded")
	for index in 60:
		mouse(MOUSE_BUTTON_WHEEL_DOWN, true)
	check(mode.distance == mode.MAX_DISTANCE, "zoom-out bounded")
	mouse(MOUSE_BUTTON_RIGHT, true)
	motion(Vector2(0, 10000))
	check(mode.target_pitch == mode.MIN_PITCH, "pitch cannot cross overhead")
	motion(Vector2(0, -20000))
	check(mode.target_pitch == mode.MAX_PITCH, "pitch cannot cross ground/horizon")
	mode.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not mode.dragging, "focus loss releases orbit")
	mode.distance = 5.5
	mode.target_pitch = -PI / 8
	mode.target_yaw = PI / 2
	await frames(50)
	Input.action_press("move_forward")
	scene.input_adapter.set_physics_process(true)
	await frames(1)
	scene.input_adapter.set_physics_process(false)
	var forward: Vector3 = -scene.camera.global_basis.z
	forward.y = 0
	check(
		scene.actor.movement_intent.dot(forward.normalized()) > .99,
		"keyboard movement follows the orbit camera on ground"
	)
	scene.input_adapter.clear_input()
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = Vector2(100, 200)
	touch.pressed = true
	scene.input_adapter.handle_touch(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(100, 135)
	scene.input_adapter.handle_touch(drag)
	scene.input_adapter.set_physics_process(true)
	await frames(1)
	scene.input_adapter.set_physics_process(false)
	check(
		scene.actor.movement_intent.dot(forward.normalized()) > .99,
		"existing touch stick follows active camera"
	)
	scene.input_adapter.clear_input()
	await obstruction()
	await orientation_and_modals()
	Input.action_press("move_forward")
	key(KEY_C)
	check(Input.is_action_pressed("move_forward"), "camera toggle preserves held keyboard input")
	scene.input_adapter.clear_input()
	await frames(10)
	check(scene.camera == original and original.current, "C restores exact original camera")
	check(
		original.projection == Camera3D.PROJECTION_ORTHOGONAL and original.size > 0,
		"original orthographic rig/projection retained"
	)
	check(scene.input_adapter.camera == original, "default controls restored")
	await walk_stairs()
	await tour()
	for place in ["scandale", "street", "lourizan"]:
		var point: Array = {
			"scandale": [1, .05, 3.5], "street": [4.35, 2.4, 0], "lourizan": [9.6, .05, 0]
		}[place]
		scene.handle_packet({"type": "travelled", "place": place, "position": point})
		scene.input_adapter.set_physics_process(false)
		await frames(8)
		check(
			mode.enabled and scene.camera == mode.perspective,
			"travel retains optional view: " + place
		)
	check(
		not mode.signs.is_empty() and not mode.foliage.is_empty(),
		"return travel retargets original signs/foliage"
	)
	mode.toggle()
	await frames(2)
	for sign in mode.signs:
		check(
			is_equal_approx(sign.label.pixel_size, sign.pixel_size), "original sign size restored"
		)
	var foliage_restored := true
	for state in mode.foliage:
		foliage_restored = (
			foliage_restored and state.material.get_shader_parameter("wall_fade") == state.fade
		)
	check(foliage_restored, "all original foliage fade settings restored")
	print("Camera modes: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func obstruction() -> void:
	await frames(45)
	var wall := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4, 5, .3)
	collider.shape = shape
	wall.add_child(collider)
	root.add_child(wall)
	wall.global_transform = Transform3D(
		mode.arm.global_basis, mode.global_position + mode.arm.global_basis.z * 1.5
	)
	await frames(15)
	check(mode.arm.get_hit_length() < 2.0, "SpringArm stops before a real solid wall")
	check(
		scene.camera.global_position.distance_to(mode.global_position) < 2.0,
		"camera stays in front of obstruction"
	)
	check(not scene.presenter.visible, "compressed arm avoids billboard close-up")
	wall.queue_free()
	await frames(15)
	check(scene.presenter.visible, "local sprite returns with camera clearance")
	check(mode.arm.get_hit_length() > 3.0, "arm extends when obstruction removed")
	# Following remains smooth without warping the player.
	var before: Vector3 = mode.global_position
	scene.actor.position += Vector3.RIGHT * .5
	await frames(1)
	check(mode.global_position.distance_to(before) < .5, "follow displacement is smoothed")
	await frames(50)
	check(
		mode.global_position.distance_to(scene.actor.position + Vector3.UP * 1.2) < .02,
		"smooth follow converges on player"
	)


func orientation_and_modals() -> void:
	scene.presenter.set_physics_process(false)
	scene.world_facing = Vector3.LEFT
	scene.present_motion(Vector3.ZERO)
	var first: StringName = scene.facing
	mode.target_yaw += PI
	await frames(55)
	scene.present_motion(Vector3.ZERO)
	check(scene.facing != first, "standing local sprite reorients when orbiting")
	var remote_data := {
		"name": "Segundo",
		"appearance": Catalog.preset(true),
		"position": [11, .05, 0],
		"direction": [-1, 0, 0],
		"walking": false
	}
	scene.remote_players.update_players({"second": remote_data})
	await frames(2)
	var remote: Dictionary = scene.remote_players.players.second
	first = remote.facing
	scene.world_view.handle(
		{
			"type": "snapshot",
			"place": "lourizan",
			"npcs": {"LucasMaconheiro": {"position": [5, .05, 4.5], "walking": false}}
		}
	)
	var residents := {}
	for path in scene.world_view.Destinations.SPEAKERS.lourizan:
		var resident: Node3D = scene.world_view.location.get_node(path)
		var point: Vector3 = resident.global_position
		residents[path] = {"position": [point.x, point.y, point.z], "walking": false}
	scene.world_view.handle({"type": "snapshot", "place": "lourizan", "npcs": residents})
	await frames(2)
	var npc: Node3D = scene.world_view.location.get_node("LucasMaconheiro")
	var npc_facing: StringName = npc.facing
	mode.target_yaw += PI
	await frames(55)
	check(remote.facing != first, "idle remote sprite reorients without a new packet")
	check(npc.facing != npc_facing, "idle NPC reorients without new motion")
	for path in scene.world_view.Destinations.SPEAKERS.lourizan:
		var resident: Node3D = scene.world_view.location.get_node(path)
		check(
			resident.sprite.sprite_frames.has_animation("idle_" + String(resident.facing)),
			"authored resident always uses an existing pose: " + path
		)
	check(not remote.actor.is_physics_processing(), "remote actors remain presentation only")
	scene.handle_packet({"type": "talked", "speaker": "LucasMaconheiro", "pages": ["Hola."]})
	var enabled: bool = mode.enabled
	key(KEY_C)
	mouse(MOUSE_BUTTON_RIGHT, true)
	check(mode.enabled == enabled and not mode.dragging, "dialogue blocks toggle and orbit")
	scene.world_view.dialogue.close()
	scene.input_adapter.set_physics_process(false)
	mouse(MOUSE_BUTTON_RIGHT, true)
	scene.connection_error("fixture")
	await frames(2)
	check(not mode.dragging and not mode.can_control(), "disconnect releases orbit")
	scene.handle_packet(
		{
			"type": "welcome",
			"character":
			{
				"appearance": Catalog.preset(),
				"place": "lourizan",
				"position": [9.6, .05, 0],
				"saved_at": "fixture"
			}
		}
	)
	scene.input_adapter.set_physics_process(false)
	check(mode.enabled and scene.camera == mode.perspective, "rejoin keeps selected local view")
	scene.presenter.set_physics_process(true)


func walk_stairs() -> void:
	# The same metre-scale actor climbs the original stairs in the perspective view.
	mode.toggle()
	for point in [
		Vector3(8.4, 0, 10.8), Vector3(6.72, 0, 10.8), Vector3(4.2, 0, 10.8), Vector3(.6, 0, 10.8)
	]:
		await walk_to(point)
	check(scene.actor.position.y > 4.1, "perspective route climbs original staircase")
	await comparison("terrace", PI / 2)
	for point in [Vector3(4.2, 0, 10.8), Vector3(8.4, 0, 10.8)]:
		await walk_to(point)
	check(scene.actor.position.y < .3, "perspective route descends original staircase")


func tour() -> void:
	for entry in [
		["forecourt", Vector3(9.6, .05, 0), PI / 2],
		["garden", Vector3(12, .05, 18), PI / 2],
		["npc", Vector3(7, .05, 4.5), PI / 2],
		["salon", Vector3(-90, .05, 5.9), 0.0],
		["salon-wall", Vector3(-96.8, .05, 0), -PI / 2]
	]:
		scene.actor.position = entry[1]
		scene.actor.velocity = Vector3.ZERO
		scene.camera_rig.snap_to_target()
		mode.snap_to_target()
		await frames(25)
		check(scene.actor.is_on_floor(), "tour is grounded: " + entry[0])
		await comparison(entry[0], entry[2])


func comparison(label: String, yaw: float) -> void:
	if mode.enabled:
		mode.toggle()
	await frames(12)
	await capture(label + "-orthographic")
	mode.toggle()
	mode.target_yaw = yaw
	mode.target_pitch = -PI / 8
	await frames(55)
	scene.present_motion(Vector3.ZERO)
	await capture(label + "-perspective")
	check(
		scene.presenter.sprite_frames.get_animation_names().size() == 16,
		"all canonical idle/walk directions retained: " + label
	)


func walk_to(point: Vector3) -> void:
	for index in 700:
		var offset: Vector3 = point - scene.actor.position
		offset.y = 0
		if offset.length() < .18:
			scene.actor.set_movement_intent(Vector3.ZERO)
			await frames(8)
			return
		scene.actor.set_movement_intent(offset.normalized() * minf(1, offset.length() * 4))
		await physics_frame
	check(false, "perspective route blocked at " + str(scene.actor.position))
	scene.actor.set_movement_intent(Vector3.ZERO)


func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event, true)


func mouse(button: MouseButton, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = Vector2(100, 100)
	event.button_index = button
	event.pressed = pressed
	root.push_input(event, true)


func motion(relative: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = Vector2(100, 100)
	event.relative = relative
	root.push_input(event, true)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame


func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless" or "--capture" not in OS.get_cmdline_user_args():
		return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://../build/verification/camera")
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder.path_join(label + ".png"))


func check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		push_error(label)
