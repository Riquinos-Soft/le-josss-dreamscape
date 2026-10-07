extends Node3D
## A fictional dream salon, authored as a cutaway within the Lourizán location.

var batches: Dictionary = {}
var ivory: ShaderMaterial
var gold: ShaderMaterial
var walnut: ShaderMaterial
var velvet: ShaderMaterial
var dark: ShaderMaterial
var glass: ShaderMaterial
var glow: ShaderMaterial


func _ready() -> void:
	ivory = paint("ded1b3")
	gold = paint("b89750")
	walnut = paint("503736")
	velvet = paint("6b304d")
	dark = paint("292539")
	glass = paint("536c8e")
	glow = paint("ffe1a1")
	build_shell()
	build_furniture()
	build_chandelier()
	for material in batches:
		var mesh := MeshInstance3D.new()
		mesh.mesh = batches[material].commit()
		mesh.material_override = material
		add_child(mesh)


func paint(color: String, pattern := 0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/salon_surface.gdshader")
	material.set_shader_parameter("paint", Color(color))
	material.set_shader_parameter("pattern", pattern)
	return material


func piece(mesh: Mesh, at: Vector3, material: Material, rotation := Vector3.ZERO) -> void:
	if not batches.has(material):
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		batches[material] = surface
	batches[material].append_from(mesh, 0, Transform3D(Basis.from_euler(rotation), at))


func box(at: Vector3, size: Vector3, material: Material, solid := false) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	piece(mesh, at, material)
	if solid:
		var body := StaticBody3D.new()
		body.position = at
		body.add_to_group("placement_obstacle")
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		add_child(body)


func column(at: Vector3, radius: float, height: float, material: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	piece(mesh, at, material)


func ball(at: Vector3, radius: float, material: Material) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 10
	mesh.rings = 5
	piece(mesh, at, material)


func build_shell() -> void:
	# 16 x 18 metres. Back walls are tall; camera-facing walls form a low cutaway.
	box(Vector3(0, -0.16, 0), Vector3(16.4, 0.32, 18.4), paint("c9c2ae", 1))
	var floor_body := StaticBody3D.new()
	floor_body.name = "MarbleFloor"
	var floor_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(16.4, 0.32, 18.4)
	floor_shape.shape = shape
	floor_shape.position.y = -0.16
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	box(Vector3(-8, 2.4, 0), Vector3(0.3, 4.8, 18.4), ivory, true)
	box(Vector3(0, 2.4, -9), Vector3(16.4, 4.8, 0.3), ivory, true)
	box(Vector3(8, 0.28, 0), Vector3(0.3, 0.56, 18.4), walnut, true)
	box(Vector3(0, 0.28, 9), Vector3(16.4, 0.56, 0.3), walnut, true)
	for y in [0.12, 1.2, 1.35, 4.45, 4.72]:
		box(Vector3(-7.78, y, 0), Vector3(0.16, 0.10, 18), gold)
		box(Vector3(0, y, -8.78), Vector3(16, 0.10, 0.16), gold)
	for z in [-7.5, -4.5, -1.5, 1.5, 4.5, 7.5]:
		box(Vector3(-7.76, 0.65, z), Vector3(0.08, 0.88, 2.65), walnut)
		window(z)
	for x in [-6.0, -3.0, 3.0, 6.0]:
		box(Vector3(x, 0.65, -8.76), Vector3(2.65, 0.88, 0.08), walnut)
		box(Vector3(x, 2.8, -8.72), Vector3(2.20, 2.45, 0.12), gold)
		box(Vector3(x, 2.8, -8.62), Vector3(1.98, 2.23, 0.12), velvet)
		box(Vector3(x, 2.8, -8.53), Vector3(1.82, 2.07, 0.08), glass)
	for at in [Vector3(-6.8, 0, -7.7), Vector3(-6.8, 0, 7.4), Vector3(6.8, 0, -7.7)]:
		column(at + Vector3.UP * 2.15, 0.25, 4.1, ivory)
		for y in [0.15, 0.35, 3.95, 4.2]:
			box(at + Vector3.UP * y, Vector3(0.75, 0.18, 0.75), gold)
	# Central woven runner and border keep a clear route between the furnishings.
	box(Vector3(0, 0.012, 0.7), Vector3(4.3, 0.025, 12.8), gold)
	box(Vector3(0, 0.032, 0.7), Vector3(4.05, 0.018, 12.55), paint("6c2946", 2))
	# Small skylight motifs set into the cutaway floor; decorative and collidable floor underneath.
	for x in [-6.9, 6.9]:
		box(Vector3(x, 0.02, 0), Vector3(0.14, 0.025, 17.8), gold)


func window(z: float) -> void:
	box(Vector3(-7.75, 2.85, z), Vector3(0.10, 2.75, 1.6), glass)
	for offset in [-0.8, 0.0, 0.8]:
		box(Vector3(-7.63, 2.85, z + offset), Vector3(0.12, 2.9, 0.06), gold)
	for y in [1.45, 2.7, 4.25]:
		box(Vector3(-7.63, y, z), Vector3(0.12, 0.08, 1.75), gold)
	for side in [-1.0, 1.0]:
		for fold in 3:
			column(
				Vector3(-7.35 + fold * 0.05, 2.9, z + side * (0.85 + fold * 0.1)),
				0.12,
				2.95,
				velvet
			)
		box(Vector3(-7.15, 2.25, z + side), Vector3(0.32, 0.10, 0.3), gold)
	box(Vector3(-7.37, 4.42, z), Vector3(0.36, 0.18, 2.4), gold)


func sofa(at: Vector3) -> void:
	box(at + Vector3.UP * 0.43, Vector3(2.8, 0.48, 1.0), velvet, true)
	box(at + Vector3(0, 0.9, -0.43), Vector3(2.8, 0.8, 0.22), velvet, true)
	for x in [-1.3, 1.3]:
		box(at + Vector3(x, 0.65, 0), Vector3(0.2, 0.65, 1.0), gold)
		for z in [-0.35, 0.35]:
			column(at + Vector3(x, 0.13, z), 0.08, 0.26, walnut)
	for x in [-0.85, 0.0, 0.85]:
		box(at + Vector3(x, 0.71, 0.02), Vector3(0.76, 0.12, 0.7), paint("97476a"))


func build_furniture() -> void:
	sofa(Vector3(-4.6, 0, -3.5))
	sofa(Vector3(4.6, 0, -3.5))
	sofa(Vector3(-4.6, 0, 3.7))
	for at in [Vector3(-4.6, 0, -1.7), Vector3(4.6, 0, -1.7), Vector3(-4.6, 0, 5.5)]:
		box(at + Vector3.UP * 0.55, Vector3(1.8, 0.15, 0.8), walnut, true)
		box(at + Vector3.UP * 0.64, Vector3(1.65, 0.03, 0.65), gold)
		for x in [-0.7, 0.7]:
			column(at + Vector3(x, 0.25, 0), 0.08, 0.5, walnut)
		column(at + Vector3.UP * 0.86, 0.13, 0.4, ivory)
		ball(at + Vector3.UP * 1.14, 0.24, paint("b377a1"))
	# A grand fireplace, mirrored overmantel and warm candle clusters.
	box(Vector3(0, 1.15, -8.25), Vector3(3.6, 2.3, 0.85), walnut, true)
	box(Vector3(0, 0.8, -7.77), Vector3(2.15, 1.4, 0.12), dark)
	for x in [-1.5, 1.5]:
		box(Vector3(x, 1.0, -7.73), Vector3(0.5, 1.85, 0.55), ivory)
	box(Vector3(0, 2.15, -7.85), Vector3(3.8, 0.23, 1.1), ivory)
	box(Vector3(0, 3.2, -8.4), Vector3(2.7, 1.6, 0.25), gold)
	box(Vector3(0, 3.2, -8.24), Vector3(2.45, 1.35, 0.08), glass)
	for x in [-0.6, -0.3, 0.0, 0.3, 0.6]:
		column(Vector3(x, 0.42, -7.62), 0.075, 0.6 + absf(x) * 0.2, glow)
	# Display console and old books at the opposite side, leaving the exit route clear.
	box(Vector3(5.7, 0.5, 4.9), Vector3(2.9, 1.0, 0.95), walnut, true)
	box(Vector3(5.7, 1.04, 4.9), Vector3(3.0, 0.12, 1.1), gold)
	for i in 6:
		box(
			Vector3(4.8 + i * 0.25, 1.28, 4.9),
			Vector3(0.18, 0.4 + (i % 2) * 0.12, 0.4),
			velvet if i % 2 == 0 else glass
		)
	for at in [Vector3(5.6, 0, -6.9), Vector3(-5.5, 0, 7.4)]:
		column(at + Vector3.UP * 0.4, 0.4, 0.8, gold)
		for i in 5:
			ball(
				at + Vector3(sin(i * 2.1) * 0.3, 1 + i * 0.12, cos(i * 2.1) * 0.3),
				0.4,
				paint("416854")
			)


func build_chandelier() -> void:
	# Suspended towards the back; it never covers the arrival or central walking lane.
	var center := Vector3(0, 3.9, -4.8)
	column(center + Vector3.UP * 0.55, 0.06, 1.0, gold)
	ball(center, 0.20, gold)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.7
	ring.outer_radius = 0.78
	ring.rings = 16
	ring.ring_segments = 6
	piece(ring, center - Vector3.UP * 0.25, gold)
	for i in 8:
		var angle := i * TAU / 8.0
		var at := center + Vector3(cos(angle) * 0.75, -0.1, sin(angle) * 0.75)
		column(at, 0.055, 0.38, ivory)
		ball(at + Vector3.UP * 0.24, 0.09, glow)
		ball(at - Vector3.UP * 0.42, 0.065, glass)
