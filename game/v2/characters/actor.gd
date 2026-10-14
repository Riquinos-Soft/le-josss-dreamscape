extends CharacterBody3D
## Physics consumes world-space intent, independently of input and appearance.

signal respawned

const SPEED := 4.0
const STEP_HEIGHT := 0.25
var movement_intent := Vector3.ZERO
var spawn_position := Vector3.ZERO


func _ready() -> void:
	spawn_position = position
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.3
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.8
	collider.shape = capsule
	collider.position.y = 0.9
	add_child(collider)


func set_movement_intent(value: Vector3) -> void:
	movement_intent = (
		Vector3(value.x, 0, value.z).limit_length(1.0) if value.is_finite() else Vector3.ZERO
	)


func _physics_process(delta: float) -> void:
	if position.y < -5.0:
		respawn()
		return
	velocity.x = movement_intent.x * SPEED
	velocity.z = movement_intent.z * SPEED
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor():
		try_step(Vector3(velocity.x, 0, velocity.z) * delta)
	move_and_slide()


func respawn() -> void:
	position = spawn_position
	velocity = Vector3.ZERO
	movement_intent = Vector3.ZERO
	reset_physics_interpolation()
	respawned.emit()


func try_step(motion: Vector3) -> void:
	if motion.is_zero_approx():
		return
	var obstruction := KinematicCollision3D.new()
	if not test_move(global_transform, motion, obstruction):
		return
	if obstruction.get_normal().y >= cos(floor_max_angle):
		return
	var raised := global_transform.translated(Vector3.UP * STEP_HEIGHT)
	if test_move(global_transform, Vector3.UP * STEP_HEIGHT) or test_move(raised, motion):
		return
	raised.origin += motion
	var landing := KinematicCollision3D.new()
	if test_move(raised, Vector3.DOWN * STEP_HEIGHT, landing):
		global_position.y = raised.origin.y + landing.get_travel().y
