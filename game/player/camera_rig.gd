extends Node3D
## Fixed heading and elevation; only the follow position changes.

@export var target: Node3D
@export var follow_sharpness: float = 8.0
@export var avoid_world_geometry: bool = false
var camera_offset := Vector3.ZERO
var clear_fraction: float = 1.0


func _ready() -> void:
	camera_offset = $Camera.position
	global_position = target.global_position + Vector3.UP * 0.9
	$Camera.look_at(global_position)


func snap_to_target() -> void:
	global_position = target.global_position + Vector3.UP * 0.9
	clear_fraction = 1.0
	$Camera.position = camera_offset
	reset_physics_interpolation()


func _process(delta: float) -> void:
	var target_position := target.get_global_transform_interpolated().origin + Vector3.UP * 0.9
	global_position = global_position.lerp(target_position, 1.0 - exp(-follow_sharpness * delta))
	if avoid_world_geometry:
		$Camera.position = camera_offset * clear_fraction


func _physics_process(_delta: float) -> void:
	if not avoid_world_geometry:
		return
	var query := PhysicsRayQueryParameters3D.create(
		global_position, global_position + camera_offset, 1
	)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	clear_fraction = 1.0
	if not hit.is_empty():
		clear_fraction = clampf(
			(global_position.distance_to(hit.position) - 0.35) / camera_offset.length(), 0.08, 1.0
		)
