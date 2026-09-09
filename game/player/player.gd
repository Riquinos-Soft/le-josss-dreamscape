extends CharacterBody3D

const MovementDirection = preload("res://player/movement_direction.gd")

@export var movement_orientation: Node3D
@export var speed: float = 4.0
@export var mouse_dead_zone: float = 0.35
@export var mouse_full_speed_distance: float = 2.5
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
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	if not direction.is_zero_approx():
		visual.rotation.y = atan2(-direction.x, -direction.z)


func mouse_movement_direction() -> Vector3:
	var camera := movement_orientation as Camera3D
	if camera == null:
		return Vector3.ZERO
	var mouse := get_viewport().get_mouse_position()
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(
		camera.project_ray_origin(mouse), camera.project_ray_normal(mouse)
	)
	if hit == null:
		return Vector3.ZERO
	return MovementDirection.from_world_target(
		global_position, hit, mouse_dead_zone, mouse_full_speed_distance
	)
