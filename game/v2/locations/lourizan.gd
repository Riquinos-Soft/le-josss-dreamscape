extends RefCounted
## The existing authored palace and garden, shared by account client and authority.

const PLACE_ID := "lourizan"
const ARRIVAL := Vector3(9.6, 0.05, 0)
const MIN_POSITION := Vector3(-25, -0.1, -33.4)
const MAX_POSITION := Vector3(29.8, 6, 33.4)
const Destinations = preload("res://v2/locations/destinations.gd")


static func create() -> Node3D:
	return Destinations.create(PLACE_ID)


static func contains_saved_position(at: Vector3) -> bool:
	return Destinations.valid_position(PLACE_ID, at)
