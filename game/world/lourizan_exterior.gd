extends Node3D
## Authored facade and forecourt from photographic reference, batched by material.

@export var place_scale := 1.2
var architecture: Node3D
var batches: Dictionary = {}
var stone: ShaderMaterial
var trim: ShaderMaterial
var shadow: ShaderMaterial
var slate: ShaderMaterial
var glass: ShaderMaterial
var frame: ShaderMaterial
var reflection: ShaderMaterial
var green: ShaderMaterial
var leaf: ShaderMaterial
var bloom: ShaderMaterial


func _ready() -> void:
	architecture = Node3D.new()
	architecture.name = "Architecture"
	architecture.scale = Vector3.ONE * place_scale
	add_child(architecture)
	stone = paint(Color("a9a18a"), 1)
	trim = paint(Color("d5cbb0"))
	shadow = paint(Color("68685f"), 1)
	slate = paint(Color("354555"), 2)
	glass = paint(Color("263f46"))
	frame = paint(Color("c9d4c4"))
	reflection = paint(Color("75918a"))
	green = paint(Color("263f32"))
	leaf = paint(Color("526c42"))
	bloom = paint(Color("bb7181"))
	build_palace()
	build_stairs()
	build_garden()
	for material in batches:
		var visual := MeshInstance3D.new()
		visual.mesh = batches[material].commit()
		visual.material_override = material
		architecture.add_child(visual)
	for marker in ["Arrival", "Exit", "Player"]:
		if has_node(marker):
			get_node(marker).position *= place_scale
	if has_node("Player"):
		$Player.spawn_transform = $Player.transform
		$CameraRig.base_orthographic_size = 32.0
		$CameraRig/Camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		$CameraRig.focus_height = 10.5
		$CameraRig.snap_to_target()


func paint(color: Color, pattern: int = 0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/lourizan_architecture.gdshader")
	material.set_shader_parameter("paint", color)
	material.set_shader_parameter("pattern", pattern)
	return material


func piece(mesh: Mesh, position: Vector3, material: Material, rotation := Vector3.ZERO) -> void:
	if not batches.has(material):
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		batches[material] = surface
	batches[material].append_from(mesh, 0, Transform3D(Basis.from_euler(rotation), position))


func box(position: Vector3, size: Vector3, material: Material, solid := false) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	piece(mesh, position, material)
	if solid:
		var shape := BoxShape3D.new()
		shape.size = size
		collision(position, shape)


func collision(position: Vector3, shape: Shape3D) -> void:
	var body := StaticBody3D.new()
	body.position = position
	var collider := CollisionShape3D.new()
	collider.shape = shape
	body.add_child(collider)
	architecture.add_child(body)


func column(position: Vector3, radius: float, height: float, material: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.88
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	piece(mesh, position, material)


func orb(position: Vector3, radius: float, material: Material) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	piece(mesh, position, material)


func roof(center: Vector3, width: float, depth: float) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var corners: Array[Vector3] = []
	for level in [0.0, 2.4]:
		var inset := 0.0 if level == 0 else 1.2
		for point in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			corners.append(
				Vector3(point.x * (depth / 2 - inset), level, point.y * (width / 2 - inset))
			)
	for side in 4:
		var next := (side + 1) % 4
		for index in [side, side + 4, next, next, side + 4, next + 4]:
			surface.add_vertex(corners[index])
	surface.generate_normals()
	surface.index()
	piece(surface.commit(), center, slate)
	box(center + Vector3.UP * 2.4, Vector3(depth - 2.2, 0.15, width - 2.2), slate)
	box(center, Vector3(depth + 0.25, 0.22, width + 0.25), trim)


func window(at: Vector3, width := 1.25, height := 2.6) -> void:
	box(at, Vector3(0.13, height, width), glass)
	for z in [-width / 2, 0.0, width / 2]:
		box(at + Vector3(0.10, 0, z), Vector3(0.13, height + 0.18, 0.08), frame)
	for y in [-height / 2, height / 2, 0.25]:
		box(at + Vector3(0.10, y, 0), Vector3(0.14, 0.08, width), frame)
	box(at + Vector3(0.13, -height / 2 - 0.16, 0), Vector3(0.4, 0.19, width + 0.32), trim)
	box(at + Vector3(0.13, height / 2 + 0.16, 0), Vector3(0.4, 0.20, width + 0.32), trim)
	box(at + Vector3(0.09, 0.65, -width * 0.23), Vector3(0.10, 1.1, 0.15), reflection)


func balustrade(start: Vector3, end: Vector3) -> void:
	var length := start.distance_to(end)
	var along_z := absf(end.z - start.z) > absf(end.x - start.x)
	var size := Vector3(0.27, 0.16, length) if along_z else Vector3(length, 0.16, 0.27)
	box((start + end) / 2 + Vector3.UP * 0.9, size, trim)
	box((start + end) / 2, size, shadow)
	for index in range(ceili(length / 0.45) + 1):
		var base := start.lerp(end, float(index) / ceili(length / 0.45))
		column(base + Vector3.UP * 0.45, 0.085, 0.78, trim)
		orb(base + Vector3.UP * 0.36, 0.13, trim)


func build_palace() -> void:
	box(Vector3(-8, 4.55, 0), Vector3(10, 9.1, 38), stone, true)
	for y in [0.3, 3.65, 4.0, 8.75, 9.15]:
		box(Vector3(-2.85, y, 0), Vector3(0.55, 0.22, 38.4), trim)
	for z in range(-17, 18, 2):
		window(Vector3(-2.84, 6.45, z), 1.45, 3.55)
		box(Vector3(-2.64, 6.35, z + 0.95), Vector3(0.32, 4.65, 0.25), trim)
	# The two raised glazed pavilions and their steep slate mansards.
	for z in [-10.0, 10.0]:
		box(Vector3(-6.25, 10.3, z), Vector3(7.3, 3.5, 6.5), stone)
		for offset in [-2.1, 0.0, 2.1]:
			window(Vector3(-2.55, 10.35, z + offset), 1.65, 2.7)
		roof(Vector3(-6.25, 12.15, z), 6.9, 7.7)
		column(Vector3(-6.25, 15.1, z), 0.09, 1.1, trim)
		var dormer := CylinderMesh.new()
		dormer.top_radius = 0.68
		dormer.bottom_radius = 0.68
		dormer.height = 0.24
		dormer.radial_segments = 16
		piece(dormer, Vector3(-2.05, 13.0, z), trim, Vector3(0, 0, PI / 2))
		dormer = dormer.duplicate()
		dormer.top_radius = 0.47
		dormer.bottom_radius = 0.47
		piece(dormer, Vector3(-1.91, 13.0, z), glass, Vector3(0, 0, PI / 2))
	# Central clock pavilion, pilasters, upper balcony and entry.
	box(Vector3(-5.6, 9.8, 0), Vector3(6.8, 2.5, 6.2), stone)
	roof(Vector3(-5.6, 11.2, 0), 6.6, 7.2)
	box(Vector3(-2.0, 12.0, 0), Vector3(0.65, 2.6, 2.35), trim)
	var face := CylinderMesh.new()
	face.top_radius = 0.76
	face.bottom_radius = 0.76
	face.height = 0.10
	face.radial_segments = 32
	piece(face, Vector3(-1.60, 12.10, 0), frame, Vector3(0, 0, PI / 2))
	box(Vector3(-1.52, 12.36, 0), Vector3(0.08, 0.56, 0.07), slate)
	box(Vector3(-1.51, 12.10, 0.22), Vector3(0.08, 0.07, 0.5), slate)
	window(Vector3(-2.05, 6.4, 0), 2.3, 3.55)
	for z in [-1.75, 1.75]:
		column(Vector3(-1.9, 6.6, z), 0.22, 4.55, trim)
	box(Vector3(-1.3, 5.1, 0), Vector3(2.6, 0.25, 4.0), trim)
	balustrade(Vector3(0, 5.25, -1.9), Vector3(0, 5.25, 1.9))
	# Triangular pediment and the vaulted door beneath the terrace.
	var pediment := SurfaceTool.new()
	pediment.begin(Mesh.PRIMITIVE_TRIANGLES)
	for point in [Vector3(-1.9, 9.05, -3.1), Vector3(-1.9, 10.5, 0), Vector3(-1.9, 9.05, 3.1)]:
		pediment.add_vertex(point)
	pediment.generate_normals()
	pediment.index()
	piece(pediment.commit(), Vector3.ZERO, trim)
	# Raised terrace leaves the two flights open at each end.
	box(Vector3(-0.75, 1.8, 0), Vector3(4.5, 3.6, 24), shadow, true)
	box(Vector3(-0.75, 3.62, 0), Vector3(4.8, 0.12, 24.2), trim)
	balustrade(Vector3(1.6, 3.7, -6), Vector3(1.6, 3.7, 6))
	box(Vector3(1.52, 0.8, 0), Vector3(0.1, 1.6, 1.85), glass)
	var arch := CylinderMesh.new()
	arch.top_radius = 0.94
	arch.bottom_radius = 0.94
	arch.height = 0.10
	arch.radial_segments = 24
	piece(arch, Vector3(1.54, 1.65, 0), glass, Vector3(0, 0, PI / 2))
	for index in 13:
		var angle := float(index) * PI / 12
		box(
			Vector3(1.63, 1.65 + sin(angle) * 1.1, cos(angle) * 1.1),
			Vector3(0.25, 0.28, 0.28),
			trim
		)
	for z in [-1.1, 1.1]:
		box(Vector3(1.63, 0.8, z), Vector3(0.25, 1.6, 0.24), trim)
	for z in [-17.0, -14.0, -5.0, 5.0, 14.0, 17.0]:
		box(Vector3(-2.25, 0.24, z), Vector3(0.9, 0.48, 1.8), shadow)
		orb(Vector3(-2.25, 0.8, z), 0.62, green)
		orb(Vector3(-2.05, 1.0, z - 0.25), 0.38, leaf)
	for z in [-17.5, -13.7, -6, 6, 13.7, 17.5]:
		column(Vector3(-2.35, 9.7, z), 0.2, 0.85, trim)
		orb(Vector3(-2.35, 10.2, z), 0.35, green)


func build_stairs() -> void:
	for z in [-9.0, 9.0]:
		for step in 18:
			var height := (18 - step) * 0.2
			box(Vector3(1.5 + step * 0.24, height / 2, z), Vector3(0.26, height, 4.2), stone)
			box(Vector3(1.5 + step * 0.24, height, z), Vector3(0.31, 0.07, 4.3), trim)
		var ramp := ConvexPolygonShape3D.new()
		ramp.points = PackedVector3Array(
			[
				Vector3(1.35, 0, z - 2.1),
				Vector3(1.35, 3.7, z - 2.1),
				Vector3(5.85, 0, z - 2.1),
				Vector3(1.35, 0, z + 2.1),
				Vector3(1.35, 3.7, z + 2.1),
				Vector3(5.85, 0, z + 2.1)
			]
		)
		collision(Vector3.ZERO, ramp)
		for side in [-1.0, 1.0]:
			for index in 13:
				var x := 1.4 + index * 0.35
				var y := 3.6 * (1.0 - float(index) / 12)
				column(Vector3(x, y + 0.48, z + side * 2.15), 0.10, 0.85, trim)
				orb(Vector3(x, y + 0.95, z + side * 2.15), 0.14, trim)
			statue(Vector3(5.9, 0, z + side * 2.25))


func statue(base: Vector3) -> void:
	box(base + Vector3.UP * 0.4, Vector3(0.65, 0.8, 0.65), shadow)
	column(base + Vector3.UP * 1.28, 0.2, 1.05, trim)
	orb(base + Vector3.UP * 1.97, 0.19, trim)
	box(base + Vector3(0, 1.65, 0), Vector3(0.35, 0.18, 0.65), trim)


func build_garden() -> void:
	var grass := paint(Color("3a5036"))
	var paving := paint(Color("777c75"))
	box(Vector3(2, -0.20, 0), Vector3(48, 0.4, 58), grass, true)
	box(Vector3(8, 0.015, 0), Vector3(15, 0.035, 46), paving)
	for z in [-12.0, 12.0]:
		box(Vector3(13, 0.22, z), Vector3(4.5, 0.45, 10.5), shadow, true)
		box(Vector3(13, 0.46, z), Vector3(4.2, 0.08, 10.2), grass)
		for side in [-1.0, 1.0]:
			box(Vector3(13 + side * 1.9, 0.75, z), Vector3(0.5, 0.65, 9.7), green)
		for offset in [-3.5, 0.0, 3.5]:
			orb(Vector3(13, 1.0, z + offset), 0.75, leaf)
			for flower in 5:
				orb(
					Vector3(
						13 + sin(flower * 2.2) * 0.5, 1.45, z + offset + cos(flower * 2.2) * 0.5
					),
					0.15,
					bloom
				)
	for z in [-24.0, -17.0, 17.0, 24.0]:
		for x in [19.0, -15.5]:
			add_tree(Vector3(x, 0, z), 0 if z < 0 else 1)
	# Low physical perimeter makes the modeled boundary unambiguous.
	for z in [-28.5, 28.5]:
		box(Vector3(2, 0.4, z), Vector3(48, 0.8, 0.6), shadow, true)
	for x in [-21.5, 25.5]:
		box(Vector3(x, 0.4, 0), Vector3(0.6, 0.8, 58), shadow, true)


func add_tree(position: Vector3, variant: int) -> void:
	var visual := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(8, 8)
	quad.center_offset = Vector3.UP * 3.5
	visual.mesh = quad
	visual.position = position
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/street_decor.gdshader")
	material.set_shader_parameter(
		"art_texture", preload("res://assets/art/vegetation/plant_jacobo_woodland_v01.png")
	)
	material.set_shader_parameter("face_camera", true)
	material.set_shader_parameter("atlas_scale", Vector2(0.5, 0.5))
	material.set_shader_parameter("atlas_offset", Vector2(variant * 0.5, 0))
	visual.material_override = material
	architecture.add_child(visual)
