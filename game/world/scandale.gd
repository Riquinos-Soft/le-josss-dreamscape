extends Node3D
## Photo-referenced estimated interior; all geometry/art is original, in metres.

var batches := {}
var wood: ShaderMaterial
var cream: ShaderMaterial
var metal: ShaderMaterial
var dark: ShaderMaterial
var green: ShaderMaterial
var glass: ShaderMaterial
var red: ShaderMaterial


func _ready() -> void:
	wood = paint("795039", 2)
	cream = paint("c7bea0")
	metal = paint("77796d")
	dark = paint("292a29")
	green = paint("456744")
	glass = paint("a3b3a2")
	red = paint("983e40")
	build_room()
	build_counter()
	build_details()
	for material in batches:
		var visual := MeshInstance3D.new()
		visual.mesh = batches[material].commit()
		visual.material_override = material
		add_child(visual)
	var light := preload("res://world/pixel_lantern.gd").new()
	light.place_id = &"scandale"
	light.indoors = true
	light.fixture = false
	light.radius = 7
	light.bulb_height = 2.7
	add_child(light)


func paint(color: String, pattern := 0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/scandale_surface.gdshader")
	material.set_shader_parameter("paint", Color(color))
	material.set_shader_parameter("pattern", pattern)
	return material


func piece(mesh: Mesh, at: Vector3, material: Material) -> void:
	if not batches.has(material):
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		batches[material] = surface
	batches[material].append_from(mesh, 0, Transform3D(Basis.IDENTITY, at))


func box(at: Vector3, size: Vector3, material: Material, solid := false) -> StaticBody3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	piece(mesh, at, material)
	return collision(at, size) if solid else null


func collision(at: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	body.add_to_group("placement_obstacle")
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	return body


func cylinder(at: Vector3, radius: float, height: float, material: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	piece(mesh, at, material)


func build_room() -> void:
	var floor_body := box(Vector3(0, -0.15, 0), Vector3(6, 0.3, 10), paint("a76542", 1), true)
	floor_body.name = "Floor"
	floor_body.remove_from_group("placement_obstacle")
	box(Vector3(-3, 1.5, 0), Vector3(0.2, 3, 10), cream, true)
	box(Vector3(0, 1.5, -5), Vector3(6, 3, 0.2), cream, true)
	# Camera-facing walls retain low collision boundaries without hiding the aisle.
	box(Vector3(3, 0.3, 0), Vector3(0.2, 0.6, 10), cream, true)
	for x in [-1.95, 1.95]:
		box(Vector3(x, 0.3, 5), Vector3(2.1, 0.6, 0.2), cream, true)
	for z in [-3.8, -1.5, 0.8, 3.1]:
		box(Vector3(-2.86, 1.95, z), Vector3(0.05, 1.5, 1.9), paint("8e7864", 3))
	for x in [-2.1, 2.0]:
		box(Vector3(x, 1.65, -4.84), Vector3(1.45, 2.2, 0.06), paint("8e7864", 3))
	box(Vector3(0.05, 1.05, -4.82), Vector3(1.0, 2.1, 0.1), wood)
	box(Vector3(-0.43, 1.05, -4.75), Vector3(0.05, 2.1, 0.03), paint("e2ce93"))
	box(Vector3(0.05, 2.55, -4.7), Vector3(1.35, 0.85, 0.22), dark)
	box(Vector3(0.05, 2.55, -4.56), Vector3(1.15, 0.65, 0.03), paint("387799"))
	box(Vector3(0, 0.012, 4.0), Vector3(1.6, 0.024, 1.5), dark)
	var sign := Label3D.new()
	sign.text = "SCANDALE"
	sign.position = Vector3(1.95, 2.8, -4.65)
	sign.font_size = 36
	sign.pixel_size = 0.008
	sign.modulate = Color("ded0a3")
	add_child(sign)


func build_counter() -> void:
	box(Vector3(-0.95, 0.5, -0.4), Vector3(0.8, 1, 6.6), wood, true)
	box(Vector3(-0.95, 1.04, -0.4), Vector3(1.0, 0.12, 6.8), wood, true)
	box(Vector3(-1.85, 0.5, 2.65), Vector3(1.0, 1, 0.5), wood, true)
	box(Vector3(-1.85, 1.04, 2.65), Vector3(1.1, 0.12, 0.7), wood, true)
	for z in [-2.8, -1.1, 0.6, 2.1]:
		box(Vector3(-0.48, 0.52, z), Vector3(0.04, 0.7, 1.3), dark)
		box(Vector3(-0.95, 1.115, z), Vector3(0.55, 0.025, 0.72), green)
	box(Vector3(-0.3, 0.18, -0.4), Vector3(0.06, 0.06, 6.2), metal)
	for y in [0.75, 1.55, 2.15]:
		box(Vector3(-2.62, y, -0.5), Vector3(0.5, 0.09, 6.2), wood)
		for i in 15:
			bottle(Vector3(-2.6, y + 0.05, -3.3 + i * 0.4), i)
	box(Vector3(-2.65, 0.35, -0.5), Vector3(0.5, 0.7, 6.2), dark, true)
	# Overhead rack sits above the service lane, with gaps that keep the NPC readable.
	for x in [-2.2, -1.25]:
		box(Vector3(x, 2.65, -0.4), Vector3(0.07, 0.09, 6.5), metal)
		box(Vector3(x, 2.94, -0.4), Vector3(0.04, 0.04, 6.5), metal)
		for z in [-3.6, 2.8]:
			box(Vector3(x, 2.65, z), Vector3(0.06, 0.75, 0.06), metal)
	for z in [-3.4, -2.4, -1.4, 0.8, 1.8, 2.6]:
		box(Vector3(-1.72, 2.64, z), Vector3(1.0, 0.06, 0.05), metal)
		bottle(Vector3(-1.72, 2.68, z), int(z * 10))
		for x in [-2.0, -1.45]:
			cylinder(Vector3(x, 2.53, z), 0.025, 0.18, glass)
			cylinder(Vector3(x, 2.39, z), 0.075, 0.16, glass)


func bottle(at: Vector3, index: int) -> void:
	var color := green if index % 3 != 0 else cream
	cylinder(at + Vector3.UP * 0.13, 0.065, 0.26, color)
	cylinder(at + Vector3.UP * 0.3, 0.03, 0.12, color)
	box(at + Vector3(0.068, 0.13, 0), Vector3(0.01, 0.11, 0.1), cream)


func build_details() -> void:
	for z in [-3.3, 1.3, 3.1]:
		stool(Vector3(2.35, 0, z), red if z > 2 else dark)
	for z in [-2.8, 1.6]:
		stool(Vector3(0.2, 0, z), dark)
	box(Vector3(2.5, 0.95, -0.7), Vector3(0.8, 0.1, 1.8), wood, true)
	box(Vector3(2.65, 0.45, -0.7), Vector3(0.15, 0.9, 0.15), metal, true)
	# Cooler/fan stand-in at the photographed counter return.
	box(Vector3(-2.0, 0.55, 3.65), Vector3(1.3, 1.1, 0.9), metal, true)
	box(Vector3(-2.0, 0.55, 4.12), Vector3(1.1, 0.88, 0.04), dark)
	box(Vector3(-2.0, 1.25, 3.65), Vector3(0.08, 0.3, 0.08), metal)
	var fan := SphereMesh.new()
	fan.radius = 0.22
	fan.height = 0.44
	fan.radial_segments = 8
	fan.rings = 4
	piece(fan, Vector3(-2, 1.55, 3.65), metal)
	var ball := SphereMesh.new()
	ball.radius = 0.3
	ball.height = 0.6
	ball.radial_segments = 16
	ball.rings = 8
	piece(ball, Vector3(1.6, 2.65, -2.5), paint("b14c84", 4))
	box(Vector3(1.6, 2.95, -2.5), Vector3(0.025, 0.3, 0.025), dark)


func stool(at: Vector3, material: Material) -> void:
	cylinder(at + Vector3.UP * 0.72, 0.29, 0.13, material)
	for x in [-0.18, 0.18]:
		for z in [-0.18, 0.18]:
			box(at + Vector3(x, 0.34, z), Vector3(0.045, 0.68, 0.045), metal)
	collision(at + Vector3.UP * 0.35, Vector3(0.5, 0.7, 0.5))
