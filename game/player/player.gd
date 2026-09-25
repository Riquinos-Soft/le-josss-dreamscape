extends CharacterBody3D

signal respawned

const MovementDirection = preload("res://player/movement_direction.gd")

@export var movement_orientation: Node3D
@export var fall_height: float = -8.0
@export var speed: float = 4.0
@export var mouse_dead_zone: float = 0.35
@export var mouse_full_speed_distance: float = 2.5
var mouse_steering_active: bool = false
var spawn_transform: Transform3D

@onready var visual: Node3D = $Visual


func _ready() -> void:
	spawn_transform = global_transform


func respawn() -> void:
	global_transform = spawn_transform
	velocity = Vector3.ZERO
	mouse_steering_active = false
	visual.rotation = Vector3.ZERO
	reset_physics_interpolation()
	respawned.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		mouse_steering_active = false
		for action in ["move_left", "move_right", "move_forward", "move_back"]:
			Input.action_release(action)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		mouse_steering_active = event.pressed


func _physics_process(delta: float) -> void:
	if global_position.y < fall_height:
		respawn()
		return
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
	var hit: Variant = Plane(Vector3.UP, global_position.y).intersects_ray(
		camera.project_ray_origin(mouse), camera.project_ray_normal(mouse)
	)
	if hit == null:
		return Vector3.ZERO
	return MovementDirection.from_world_target(
		global_position, hit, mouse_dead_zone, mouse_full_speed_distance
	)
