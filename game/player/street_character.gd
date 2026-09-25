extends AnimatedSprite3D
## Presentation follows resolved displacement, including sliding, rather than key intent.

const DIRECTIONS: Array[StringName] = [
	&"right", &"down_right", &"down", &"down_left", &"left", &"up_left", &"up", &"up_right"
]

@export var movement_actor: CharacterBody3D
@export var movement_view: Camera3D
var facing: StringName = &"up"
var _just_respawned: bool = false


func _ready() -> void:
	# Read move_and_slide's result after the parent's default-priority physics callback.
	process_physics_priority = 1
	movement_actor.respawned.connect(_on_respawned)
	play(&"idle_up")


func _physics_process(_delta: float) -> void:
	if _just_respawned:
		_just_respawned = false
		return
	var motion := movement_actor.get_real_velocity()
	motion.y = 0.0
	var walking := motion.length() > 0.1
	if walking:
		var right := movement_view.global_basis.x
		right.y = 0.0
		var forward := -movement_view.global_basis.z
		forward.y = 0.0
		var screen_motion := Vector2(
			motion.dot(right.normalized()), -motion.dot(forward.normalized())
		)
		# Nearest 45-degree sector; half-way ties follow roundi (away from zero).
		facing = DIRECTIONS[posmod(roundi(screen_motion.angle() / (PI / 4.0)), 8)]
	var next := StringName(("walk_" if walking else "idle_") + String(facing))
	if animation != next:
		play(next)


func _on_respawned() -> void:
	_just_respawned = true
	facing = &"up"
	play(&"idle_up")
