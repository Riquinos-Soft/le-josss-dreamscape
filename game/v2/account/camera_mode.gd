extends Node3D
## Reversible client-only experiment. The original camera rig remains untouched.

const Direction = preload("res://player/directional_animation.gd")
const Movement = preload("res://player/movement_direction.gd")
const MIN_DISTANCE := 2.8
const MAX_DISTANCE := 8.0
const MIN_PITCH := -PI / 3.0
const MAX_PITCH := -PI / 36.0
const Plant = preload("res://world/vegetation/botanical_plant.gd")
const Passage = preload("res://world/lourizan_passage.gd")
var foliage: Array[Dictionary] = []
var signs: Array[Dictionary] = []
var session: Node3D
var orthographic: Camera3D
var perspective: Camera3D
var arm: SpringArm3D
var enabled := false
var dragging := false
var distance := 5.5
var yaw := 0.0
var pitch := -PI / 8.0
var target_yaw := 0.0
var target_pitch := -PI / 8.0


func _ready() -> void:
	process_physics_priority = -5
	orthographic = session.camera
	session.actor.respawned.connect(snap_to_target)
	arm = SpringArm3D.new()
	arm.name = "SpringArm"
	arm.collision_mask = 1
	arm.margin = 0.12
	var shape := SphereShape3D.new()
	shape.radius = 0.22
	arm.shape = shape
	arm.spring_length = distance
	add_child(arm)
	arm.add_excluded_object(session.actor.get_rid())
	perspective = Camera3D.new()
	perspective.name = "Perspective"
	perspective.fov = 55.0
	perspective.near = 0.08
	perspective.far = 200.0
	arm.add_child(perspective)
	arm.process_mode = Node.PROCESS_MODE_DISABLED
	snap_to_target()
	track_place()


func can_control() -> bool:
	return session.admitted and not session.leaving and not session.world_view.controls_locked


func toggle() -> void:
	if not can_control():
		return
	enabled = not enabled
	dragging = false
	session.input_adapter.clear_touch()
	session.actor.set_movement_intent(Vector3.ZERO)
	session.reorient_pending = true
	if session.presenter != null:
		session.presenter.visible = true
	if enabled:
		var facing: Vector3 = session.world_facing
		target_yaw = atan2(-facing.x, -facing.z)
		yaw = target_yaw
		target_pitch = -PI / 8.0
		pitch = target_pitch
		snap_to_target()
		arm.rotation = Vector3(pitch, yaw, 0)
		arm.spring_length = distance
	apply_view_style()
	arm.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	session.camera = perspective if enabled else orthographic
	session.camera.make_current()
	session.input_adapter.camera = session.camera
	if session.presenter != null:
		session.presenter.movement_view = session.camera
	for state in session.remote_players.players.values():
		state.presenter.movement_view = session.camera
	for path in session.world_view.Destinations.SPEAKERS[String(session.current_id)]:
		session.world_view.location.get_node(path).set_movement_view(session.camera)


func track_place() -> void:
	for state in signs:
		if is_instance_valid(state.label):
			state.label.pixel_size = state.pixel_size
			state.label.visible = state.visible
	for state in foliage:
		state.material.set_shader_parameter("wall_fade", state.fade)
	signs.clear()
	foliage.clear()
	for node in session.world_view.location.find_children("*", "Node3D", true, false):
		if node.get_script() == Plant:
			foliage.append(
				{
					"material": node.foliage_material,
					"fade": node.foliage_material.get_shader_parameter("wall_fade")
				}
			)
		elif node is Label3D and node.get_parent().get_script() == Passage:
			signs.append({"label": node, "pixel_size": node.pixel_size, "visible": node.visible})
	apply_view_style()


func apply_view_style() -> void:
	for state in signs:
		state.label.pixel_size = state.pixel_size
		state.label.visible = state.visible
	for state in foliage:
		state.material.set_shader_parameter("wall_fade", true if enabled else state.fade)


func _process(_delta: float) -> void:
	if not enabled:
		return
	for state in signs:
		var label: Label3D = state.label
		var metres := perspective.global_position.distance_to(label.global_position)
		label.pixel_size = minf(state.pixel_size, metres * .0012)
		label.visible = state.visible and not perspective.is_position_behind(label.global_position)
	for state in foliage:
		state.material.set_shader_parameter("player_position", session.actor.global_position)
	if session.presenter != null:
		# Do not let a compressed arm put the billboard across the whole near view.
		session.presenter.visible = arm.get_hit_length() > 1.4


func world_from_facing(facing: StringName) -> Vector3:
	var index := Direction.DIRECTIONS.find(facing)
	return Movement.from_view(
		Vector2.from_angle(maxi(index, 0) * PI / 4), orthographic.global_basis
	)


func snap_to_target() -> void:
	global_position = session.actor.global_position + Vector3.UP * 1.2
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	if not can_control():
		dragging = false
	if not enabled:
		return
	var focus: Vector3 = session.actor.global_position + Vector3.UP * 1.2
	var next := global_position.lerp(focus, 1.0 - exp(-10.0 * delta))
	# A lagged focus must never remain on the other side of a wall from Joss.
	var ray := PhysicsRayQueryParameters3D.create(focus, next, 1)
	if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
		next = focus
	global_position = next
	yaw = lerp_angle(yaw, target_yaw, 1.0 - exp(-14.0 * delta))
	pitch = lerpf(pitch, target_pitch, 1.0 - exp(-14.0 * delta))
	arm.rotation = Vector3(pitch, yaw, 0)
	arm.spring_length = lerpf(arm.spring_length, distance, 1.0 - exp(-12.0 * delta))


func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and not event.pressed
	):
		dragging = false
	if not can_control() or event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event is InputEventKey and event.physical_keycode == KEY_C:
		if (
			event.pressed
			and not event.echo
			and not (event.ctrl_pressed or event.meta_pressed or event.alt_pressed)
		):
			toggle()
			get_viewport().set_input_as_handled()
	elif enabled and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			get_viewport().set_input_as_handled()
		elif (
			event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]
		):
			var step := -0.5 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.5
			distance = clampf(distance + step, MIN_DISTANCE, MAX_DISTANCE)
			get_viewport().set_input_as_handled()
	elif enabled and dragging and event is InputEventMouseMotion:
		target_yaw -= event.relative.x * 0.006
		target_pitch = clampf(target_pitch - event.relative.y * 0.006, MIN_PITCH, MAX_PITCH)
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		dragging = false
