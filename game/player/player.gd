extends CharacterBody3D

const MovementDirection = preload("res://player/movement_direction.gd")

@export var movement_orientation: Node3D
@export var speed: float = 4.0
@export var mouse_dead_zone: float = 0.35
@export var mouse_full_speed_distance: float = 2.5
@export var prevent_ledge_fall: bool = false
@export var step_height: float = 0.0
var mouse_steering_active: bool = false

@onready var visual: Node3D = $Visual


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		mouse_steering_active = false
		for action in ["move_left", "move_right", "move_forward", "move_back"]:
			Input.action_release(action)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		mouse_steering_active = event.pressed


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := MovementDirection.from_view(input, movement_orientation.global_basis)
	# Keyboard has deterministic precedence so its existing behavior remains unchanged.
	if direction.is_zero_approx() and mouse_steering_active:
		direction = mouse_movement_direction()
	if prevent_ledge_fall and is_on_floor() and not has_ground_ahead(direction):
		direction = Vector3.ZERO
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity += get_gravity() * delta
	if step_height > 0 and is_on_floor():
		try_step(Vector3(velocity.x, 0, velocity.z) * delta)
	move_and_slide()
	if not direction.is_zero_approx():
		visual.rotation.y = atan2(-direction.x, -direction.z)


func has_ground_ahead(direction: Vector3) -> bool:
	if direction.is_zero_approx():
		return true
	var ahead := global_position + direction.normalized() * 0.5
	var side := direction.normalized().cross(Vector3.UP) * 0.25
	# The capsule bridges small scan cracks; only stop when its width has no support.
	for offset in [Vector3.ZERO, side, -side]:
		var query := PhysicsRayQueryParameters3D.create(
			ahead + offset + Vector3.UP * maxf(step_height + 0.1, 0.35),
			ahead + offset - Vector3.UP * 0.65,
			1
		)
		if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			return true
	return false


func try_step(motion: Vector3) -> void:
	if motion.is_zero_approx():
		return
	var obstruction := KinematicCollision3D.new()
	if not test_move(global_transform, motion, obstruction):
		return
	if obstruction.get_normal().y >= cos(floor_max_angle):
		return
	var raised := global_transform.translated(Vector3.UP * step_height)
	if test_move(global_transform, Vector3.UP * step_height) or test_move(raised, motion):
		return
	raised.origin += motion
	var landing := KinematicCollision3D.new()
	if test_move(raised, Vector3.DOWN * step_height, landing):
		# A capsule first touches a step's rounded edge, whose normal is not yet up.
		global_position.y = raised.origin.y + landing.get_travel().y


func mouse_movement_direction(screen_position: Vector2 = Vector2.INF) -> Vector3:
	var camera := movement_orientation as Camera3D
	if camera == null:
		return Vector3.ZERO
	var mouse := (
		get_viewport().get_mouse_position() if screen_position == Vector2.INF else screen_position
	)
	var hit: Variant = Plane(Vector3.UP, global_position.y).intersects_ray(
		camera.project_ray_origin(mouse), camera.project_ray_normal(mouse)
	)
	if hit == null:
		return Vector3.ZERO
	return MovementDirection.from_world_target(
		global_position, hit, mouse_dead_zone, mouse_full_speed_distance
	)
