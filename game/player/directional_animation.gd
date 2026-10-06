extends RefCounted
## Shared eight-way presentation: stable facing and uninterrupted footstep phase.

const DIRECTIONS: Array[StringName] = [
	&"right", &"down_right", &"down", &"down_left", &"left", &"up_left", &"up", &"up_right"
]
const TURN_MARGIN := PI / 36.0


static func resolve_facing(
	motion: Vector3, view: Camera3D, current: StringName, walking: bool
) -> StringName:
	var screen_motion := Vector2(motion.x, motion.z)
	if is_instance_valid(view):
		var right := view.global_basis.x
		right.y = 0.0
		var forward := -view.global_basis.z
		forward.y = 0.0
		screen_motion = Vector2(motion.dot(right.normalized()), -motion.dot(forward.normalized()))
	if screen_motion.length_squared() < 0.000001:
		return current
	var angle := screen_motion.angle()
	var previous := DIRECTIONS.find(current)
	if walking and previous >= 0:
		var difference := absf(wrapf(angle - previous * PI / 4.0, -PI, PI))
		if difference <= PI / 8.0 + TURN_MARGIN:
			return current
	return DIRECTIONS[posmod(roundi(angle / (PI / 4.0)), 8)]


static func play_direction(sprite: AnimatedSprite3D, facing: StringName, walking: bool) -> void:
	var next := StringName(("walk_" if walking else "idle_") + String(facing))
	if sprite.animation == next:
		return
	var continue_step := walking and String(sprite.animation).begins_with("walk_")
	var previous_frame := sprite.frame
	var previous_progress := sprite.frame_progress
	sprite.play(next)
	if continue_step:
		sprite.set_frame_and_progress(previous_frame, previous_progress)
