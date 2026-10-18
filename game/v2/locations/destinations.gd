extends RefCounted
## The three authored account destinations. Casa is deliberately absent.

const PATHS := {
	"lourizan": preload("res://world/locations/lourizan.tscn"),
	"street": preload("res://world/jacobo_risa_street.tscn"),
	"scandale": preload("res://world/locations/scandale.tscn")
}
const SPEAKERS := {
	"lourizan": ["LucasMaconheiro", "InesBotanica", "NarciVisitante", "Salon/BraisAnfitrion"],
	"street": [],
	"scandale": ["Bartender"]
}
const BOUNDS := {
	"lourizan": [Vector3(-25, -0.1, -33.4), Vector3(29.8, 6, 33.4)],
	"street": [Vector3(-16, -1, -50), Vector3(12, 8, 50)],
	"scandale": [Vector3(-3, -0.1, -5), Vector3(3, 4, 5)]
}


static func create(place: String, player: Node3D = null, visuals := true) -> Node3D:
	if not PATHS.has(place):
		return null
	var location: Node3D = PATHS[place].instantiate()
	if place == "street":
		location.location_only = true
		location.tracked_player = player
		for child in ["Player", "CameraRig", "HUD", "PixelPass", "TouchHUD", "ItemLoop"]:
			location.get_node(child).free()
	if not visuals:
		for child in ["Environment", "Sun", "Light"]:
			var node := location.get_node_or_null(child)
			if node != null:
				node.free()
	return location


static func valid_position(place: String, at: Vector3) -> bool:
	if not PATHS.has(place) or not at.is_finite():
		return false
	if place == "lourizan" and at.x < -70:
		return within(at, Vector3(-99, -0.1, -10), Vector3(-81, 5, 10))
	return within(at, BOUNDS[place][0], BOUNDS[place][1])


static func within(at: Vector3, low: Vector3, high: Vector3) -> bool:
	return (
		at.x >= low.x
		and at.y >= low.y
		and at.z >= low.z
		and at.x <= high.x
		and at.y <= high.y
		and at.z <= high.z
	)
