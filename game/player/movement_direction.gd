extends RefCounted
## Converts directional input to the ground plane using an assigned view basis.


static func from_view(input: Vector2, view_basis: Basis) -> Vector3:
	var forward := -view_basis.z
	forward.y = 0.0
	# A straight-down camera still has a usable screen-right direction.
	if forward.length_squared() < 0.0001:
		var view_right := view_basis.x
		view_right.y = 0.0
		forward = Vector3.UP.cross(view_right)
	forward = forward.normalized()
	var right := forward.cross(Vector3.UP)
	return (right * input.x - forward * input.y).limit_length(1.0)


## Points along the ground toward a world point, with distance represented as input strength.
static func from_world_target(
	origin: Vector3, target: Vector3, dead_zone: float, full_strength_distance: float
) -> Vector3:
	var offset := target - origin
	offset.y = 0.0
	var distance := offset.length()
	if distance <= dead_zone:
		return Vector3.ZERO
	var strength := clampf(
		(distance - dead_zone) / maxf(full_strength_distance - dead_zone, 0.001), 0.0, 1.0
	)
	return offset / distance * strength
