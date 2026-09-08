extends CharacterBody3D

const MovementDirection = preload("res://player/movement_direction.gd")

@export var movement_orientation: Node3D
@export var speed: float = 4.0
var movement_enabled: bool = true

@onready var visual: Node3D = $Visual

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		for action in ["move_left", "move_right", "move_forward", "move_back"]:
			Input.action_release(action)


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if not movement_enabled:
		input = Vector2.ZERO
	var direction := MovementDirection.from_view(input, movement_orientation.global_basis)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	if not direction.is_zero_approx():
		visual.rotation.y = atan2(-direction.x, -direction.z)
