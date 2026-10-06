extends AnimatedSprite3D
## Presentation follows resolved displacement, including sliding, rather than key intent.

const DirectionalAnimation = preload("res://player/directional_animation.gd")

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
	var was_walking := String(animation).begins_with("walk_")
	var walking := motion.length() > (0.06 if was_walking else 0.12)
	if walking:
		facing = DirectionalAnimation.resolve_facing(motion, movement_view, facing, was_walking)
	DirectionalAnimation.play_direction(self, facing, walking)


func _on_respawned() -> void:
	_just_respawned = true
	facing = &"up"
	play(&"idle_up")
