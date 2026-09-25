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
# West/east cross sections follow the actual banks and open onto the garage apron.
const CROSS_SECTIONS: Array[Vector3] = [
	Vector3(0.8, 0.48, -33),
	Vector3(4.2, 0.48, -33),
	Vector3(0.9, 0.51, -30),
	Vector3(4.4, 0.51, -30),
	Vector3(-3.2, 0.35, -25),
	Vector3(4.8, 0.62, -25),
	Vector3(0.8, 0.68, -20),
	Vector3(4.8, 0.76, -20),
	Vector3(2.0, 0.86, -15),
	Vector3(5.8, 1.00, -15),
	Vector3(2.7, 1.08, -10),
	Vector3(5.8, 1.14, -10),
	Vector3(3.4, 1.28, -5),
	Vector3(5.2, 1.39, -5),
	Vector3(1.7, 1.49, 0),
	Vector3(4.5, 1.60, 0),
	Vector3(-0.5, 1.49, 5),
	Vector3(1.6, 1.61, 5),
	Vector3(-2.4, 1.53, 10),
	Vector3(0.2, 1.49, 10),
	Vector3(-3.8, 1.09, 15),
	Vector3(-1.3, 1.24, 15),
	Vector3(-4.6, 0.92, 20),
	Vector3(-2.2, 1.04, 20),
	Vector3(-5.5, 0.77, 23),
	Vector3(-2.65, 0.84, 23),
	Vector3(-6.0, 0.66, 24.5),
	Vector3(0.5, 0.86, 24.5),
	Vector3(-6.9, 0.43, 27),
	Vector3(-1.3, 0.74, 27),
	Vector3(-8.0, 0.28, 30),
	Vector3(-5.0, 0.30, 30),
	Vector3(-8.4, 0.20, 32),
	Vector3(-5.7, 0.22, 32),
]
const GARAGE_APPROACH: Array[Vector3] = [
	Vector3(-4.5, 0.75, 25.5),
	Vector3(-2.0, 0.8, 25.5),
	Vector3(-0.4, 0.85, 25.0),
]

@export var study_material: ShaderMaterial
@export var paving_material: Material
var facade_materials: Array[ShaderMaterial] = []

@onready var street_visual: Node3D = $StreetVisual
@onready var street_collision: CollisionShape3D = $StreetCollision/Collision


func _ready() -> void:
	var visual_mesh := first_mesh(street_visual)
	if visual_mesh == null:
		push_error("The street scan has no mesh to build collision from.")
		return
	visual_mesh.material_override = study_material
	study_material.set_shader_parameter("route", PackedVector3Array(ROUTE))
	study_material.set_shader_parameter("walk_sections", PackedVector3Array(CROSS_SECTIONS))
	build_walkway()
	build_garage()
	add_plant_accents()
	$Player/Visual.hide()
	$CameraRig/Camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	$CameraRig/Camera.size = 13.5


func _process(_delta: float) -> void:
	study_material.set_shader_parameter("player_position", $Player.global_position)
	for material in facade_materials:
		material.set_shader_parameter("player_position", $Player.global_position)
	var horizontal_speed: float = $Player.velocity.dot($CameraRig/Camera.global_basis.x)
	var forward: Vector3 = -$CameraRig/Camera.global_basis.z
	forward.y = 0.0
	var vertical_speed: float = $Player.velocity.dot(forward.normalized())
	if Vector2(horizontal_speed, vertical_speed).length() > 0.1:
		var angle := Vector2(horizontal_speed, -vertical_speed).angle()
		var sector := posmod(roundi(angle / (PI / 4.0)), 8)
		$Player/PixelCharacter.frame = [3, 5, 0, 4, 2, 6, 1, 7][sector]


func build_garage() -> void:
	add_facade(
		"GarageFacade",
		Vector3(0.1, 0.78, 16.2),
		Vector3(-1.9, 0.62, 23.1),
		4.8,
		4.4,
		preload("res://assets/art/environments/building_jacobo_garage_facade_night_v01.svg")
	)
	add_facade(
		"GarageDoor",
		Vector3(-1.9, 0.62, 23.1),
		Vector3(0.9, 0.85, 24.0),
		4.4,
		3.0,
		preload("res://assets/art/environments/building_jacobo_garage_door_night_v01.svg")
	)


func add_plant_accents() -> void:
	var plants := Node3D.new()
	plants.name = "PlantAccents"
	add_child(plants)
	for section in [1, 3, 5, 7, 9, 11, 15]:
		for side in 2:
			if side == 1 and section == 11:
				continue
			var bush := Sprite3D.new()
			bush.texture = preload(
				"res://assets/art/vegetation/plant_jacobo_shrub_green_idle_v01.svg"
			)
			bush.pixel_size = 0.04
			bush.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			bush.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			bush.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			bush.position = (
				CROSS_SECTIONS[section * 2 + side] + Vector3(-0.2 if side == 0 else 0.2, 0.35, 0)
			)
			bush.flip_h = section % 2 == side
			plants.add_child(bush)


func add_facade(
	label: String,
	start: Vector3,
	end: Vector3,
	top_start: float,
	top_end: float,
	texture: Texture2D
) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var corners := [
		start, Vector3(start.x, top_start, start.z), end, Vector3(end.x, top_end, end.z)
	]
	var uvs := [Vector2(0, 1), Vector2.ZERO, Vector2.ONE, Vector2(1, 0)]
	for index in [0, 1, 2, 2, 1, 3]:
		surface.set_uv(uvs[index])
		surface.add_vertex(corners[index])
	surface.generate_normals()
	var facade := MeshInstance3D.new()
	facade.name = label
	facade.mesh = surface.commit()
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/street_facade.gdshader")
	material.set_shader_parameter("facade_texture", texture)
	facade.material_override = material
	facade_materials.append(material)
	add_child(facade)


func build_walkway() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var barrier_faces := PackedVector3Array()
	var left: Array[Vector3] = []
	var right: Array[Vector3] = []
	for index in range(0, CROSS_SECTIONS.size(), 2):
		left.append(CROSS_SECTIONS[index])
		right.append(CROSS_SECTIONS[index + 1])
	for index in left.size() - 1:
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
	# A continuous asphalt/apron surface replaces noisy scanned ground at its surveyed height.
	paving.position.y = -0.01
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
