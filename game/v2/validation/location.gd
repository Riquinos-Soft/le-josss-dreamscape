extends Node3D
## Shared collision fixture for the laboratory client and trusted authority.


func _ready() -> void:
	name = "Location"
	box(self, "Floor", Vector3(0, -0.2, 0), Vector3(14, 0.4, 12), "69745f")
	box(self, "WestWall", Vector3(-6, 1.3, -1), Vector3(0.3, 2.6, 8), "93947e")
	box(self, "DoorLeft", Vector3(-3.4, 1.3, -3), Vector3(5.2, 2.6, 0.3), "a4a08a")
	box(self, "DoorRight", Vector3(3.4, 1.3, -3), Vector3(5.2, 2.6, 0.3), "a4a08a")
	box(self, "Lintel", Vector3(0, 2.4, -3), Vector3(1.6, 0.4, 0.3), "c0b79c")
	for step in 5:
		var height := (step + 1) * 0.2
		box(
			self,
			"Step%d" % step,
			Vector3(1.3 + step * 0.6, height / 2, 0),
			Vector3(0.6, height, 2),
			"b0a78c"
		)
	box(self, "Landing", Vector3(4.8, 0.5, 0), Vector3(1.6, 1, 2), "c0b79c")


func box(parent: Node3D, label: String, at: Vector3, dimensions: Vector3, color: String) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	parent.add_child(body)
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collider.shape = shape
	body.add_child(collider)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(color)
	visual.material_override = material
	body.add_child(visual)
