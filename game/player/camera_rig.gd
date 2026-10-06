extends Node3D
## Fixed heading and elevation; only the follow position changes.

@export var target: Node3D
@export var follow_sharpness: float = 8.0
@export var avoid_world_geometry: bool = false
var camera_offset := Vector3.ZERO
var clear_fraction: float = 1.0
var displayed_fraction: float = 1.0
var base_orthographic_size: float = 0.0


func _ready() -> void:
	camera_offset = $Camera.position
	base_orthographic_size = $Camera.size
	snap_to_target()
	$Camera.look_at(global_position)
	target.respawned.connect(snap_to_target)


func snap_to_target() -> void:
	global_position = target.global_position + Vector3.UP * 0.9
	clear_fraction = 1.0
	displayed_fraction = 1.0
	$Camera.position = camera_offset
	$Camera.size = base_orthographic_size
	reset_physics_interpolation()


func _process(delta: float) -> void:
	var target_position := target.get_global_transform_interpolated().origin + Vector3.UP * 0.9
	global_position = global_position.lerp(target_position, 1.0 - exp(-follow_sharpness * delta))
	var desired_fraction := clear_fraction if avoid_world_geometry else 1.0
	var response := 16.0 if desired_fraction < displayed_fraction else 4.0
	displayed_fraction = lerpf(displayed_fraction, desired_fraction, 1.0 - exp(-response * delta))
	$Camera.position = camera_offset * displayed_fraction
	if $Camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		$Camera.size = base_orthographic_size * lerpf(0.72, 1.0, displayed_fraction)


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
