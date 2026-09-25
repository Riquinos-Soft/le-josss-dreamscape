extends Node3D
## A standalone scan trial. The imported mesh is visual data; collision belongs to this scene.

# Surveyed against the scan in meters. The noisy reconstruction stays visual only.
const ROUTE: Array[Vector3] = [
	Vector3(2.5, 0.48, -33),
	Vector3(2.5, 0.51, -30),
	Vector3(2.5, 0.57, -25),
	Vector3(2.5, 0.70, -20),
	Vector3(3.5, 0.94, -15),
	Vector3(4.1, 1.09, -10),
	Vector3(4.2, 1.30, -5),
	Vector3(3.0, 1.58, 0),
	Vector3(0.5, 1.52, 5),
	Vector3(-1.0, 1.50, 10),
	Vector3(-2.5, 1.16, 15),
	Vector3(-3.3, 0.96, 20),
	Vector3(-4.8, 0.67, 25),
	Vector3(-6.5, 0.28, 30),
	Vector3(-7.0, 0.20, 32),
]
const HALF_WIDTH: float = 1.35

@export var study_material: ShaderMaterial
@export var paving_material: Material

@onready var street_visual: Node3D = $StreetVisual
@onready var street_collision: CollisionShape3D = $StreetCollision/Collision


func _ready() -> void:
	var visual_mesh := first_mesh(street_visual)
	if visual_mesh == null:
		push_error("The street scan has no mesh to build collision from.")
		return
	visual_mesh.material_override = study_material
	study_material.set_shader_parameter("route", PackedVector3Array(ROUTE))
	study_material.set_shader_parameter("half_width", HALF_WIDTH)
	build_walkway()


func build_walkway() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var barrier_faces := PackedVector3Array()
	var left: Array[Vector3] = []
	var right: Array[Vector3] = []
	for index in ROUTE.size():
		var tangent := ROUTE[mini(index + 1, ROUTE.size() - 1)] - ROUTE[maxi(index - 1, 0)]
		var side := Vector3(tangent.z, 0, -tangent.x).normalized() * HALF_WIDTH
		left.append(ROUTE[index] - side)
		right.append(ROUTE[index] + side)
	for index in ROUTE.size() - 1:
		for vertex in [
			left[index],
			left[index + 1],
			right[index],
			right[index],
			left[index + 1],
			right[index + 1]
		]:
			surface.add_vertex(vertex)
		add_barrier(barrier_faces, left[index], left[index + 1])
		add_barrier(barrier_faces, right[index + 1], right[index])
	add_barrier(barrier_faces, right[0], left[0])
	add_barrier(barrier_faces, left[-1], right[-1])
	surface.generate_normals()
	var mesh := surface.commit()
	var paving := MeshInstance3D.new()
	paving.name = "Walkway"
	paving.mesh = mesh
	paving.material_override = paving_material
	add_child(paving)
	var shape := mesh.create_trimesh_shape()
	shape.backface_collision = true
	street_collision.shape = shape
	var barriers := CollisionShape3D.new()
	barriers.name = "Boundaries"
	var boundary_shape := ConcavePolygonShape3D.new()
	boundary_shape.set_faces(barrier_faces)
	boundary_shape.backface_collision = true
	barriers.shape = boundary_shape
	$StreetCollision.add_child(barriers)


func add_barrier(faces: PackedVector3Array, start: Vector3, end: Vector3) -> void:
	var bottom_a := start - Vector3.UP
	var bottom_b := end - Vector3.UP
	var top_a := start + Vector3.UP * 3.0
	var top_b := end + Vector3.UP * 3.0
	faces.append_array(PackedVector3Array([bottom_a, top_a, bottom_b, bottom_b, top_a, top_b]))


func first_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := first_mesh(child)
		if found != null:
			return found
	return null
