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
