extends Node3D
## A standalone scan trial. The imported mesh is visual data; collision belongs to this scene.

@export var study_material: Material

@onready var street_visual: Node3D = $StreetVisual
@onready var street_collision: CollisionShape3D = $StreetCollision/Collision


func _ready() -> void:
	var visual_mesh := first_mesh(street_visual)
	if visual_mesh == null:
		push_error("The street scan has no mesh to build collision from.")
		return
	visual_mesh.material_override = study_material
	var shape := visual_mesh.mesh.create_trimesh_shape()
	shape.backface_collision = true
	street_collision.shape = shape
	street_collision.transform = (
		$StreetCollision.global_transform.affine_inverse() * visual_mesh.global_transform
	)


func first_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := first_mesh(child)
		if found != null:
			return found
	return null
