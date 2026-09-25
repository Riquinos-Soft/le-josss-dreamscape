extends Node3D
## Fixed heading and elevation; only the follow position changes.

@export var target: Node3D
@export var follow_sharpness: float = 8.0


func _ready() -> void:
	snap_to_target()
	$Camera.look_at(global_position)
	target.respawned.connect(snap_to_target)


func snap_to_target() -> void:
	global_position = target.global_position + Vector3.UP * 0.9
	reset_physics_interpolation()


func _process(delta: float) -> void:
	var target_position := target.get_global_transform_interpolated().origin + Vector3.UP * 0.9
	global_position = global_position.lerp(target_position, 1.0 - exp(-follow_sharpness * delta))
