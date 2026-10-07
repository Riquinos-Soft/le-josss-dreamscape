extends Node3D
## Non-colliding floating castles beyond the playable boundaries, inspired by the cover.

var batches: Dictionary = {}
var island_origin := Vector3.ZERO


func _ready() -> void:
	var rock := material("282342")
	var wall := material("636082")
	var roof := material("373555")
	var light := material("ffd38b")
	var grass := material("47486b")
	var centers := [
		Vector3(39, 1, 34),
		Vector3(39, 2, -16),
		Vector3(6, 2, 44),
		Vector3(-18, 4, 44),
		Vector3(-36, 2, 14),
		Vector3(-38, 1, -21),
		Vector3(-5, 3, -44),
		Vector3(22, 5, -42)
	]
	for index in centers.size():
		var center: Vector3 = centers[index]
		island_origin = center
		var radius := 4.0 + index % 3
		var island := CylinderMesh.new()
		island.top_radius = radius
		island.bottom_radius = 0.2
		island.height = 8
		island.radial_segments = 7
		piece(island, center - Vector3.UP * 4, rock)
		island = island.duplicate()
		island.height = 0.35
		island.bottom_radius = radius
		piece(island, center, grass)
		box(center + Vector3.UP * 1.8, Vector3(radius * 1.4, 3.6, radius), wall)
		for tower in 4:
			var at := (
				center
				+ Vector3(
					(-1 if tower % 2 == 0 else 1) * radius * 0.6,
					0,
					(-1 if tower < 2 else 1) * radius * 0.42
				)
			)
			var height := 4.5 + (tower % 3) * 0.9
			box(at + Vector3.UP * height / 2, Vector3(1.3, height, 1.3), wall)
			var cone := CylinderMesh.new()
			cone.top_radius = 0
			cone.bottom_radius = 1.0
			cone.height = 2.6
			cone.radial_segments = 4
			piece(cone, at + Vector3.UP * (height + 1.3), roof)
			for y in [1.2, 2.8, 4.2]:
				box(at + Vector3(0.67, y, 0), Vector3(0.02, 0.48, 0.22), light)
				box(at + Vector3(0, y, 0.67), Vector3(0.22, 0.48, 0.02), light)
		for i in 5:
			box(
				center + Vector3(-2.2 + i * 1.1, 2.1, radius * 0.5 + 0.01),
				Vector3(0.25, 0.7, 0.02),
				light
			)
	# A celestial plane under the finite map fills the void with drifting purple nebulae.
	var sky := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(360, 360)
	sky.mesh = plane
	sky.position.y = -15
	var sky_material := ShaderMaterial.new()
	sky_material.shader = preload("res://world/dream_sky.gdshader")
	sky.material_override = sky_material
	add_child(sky)
	for mat in batches:
		var mesh := MeshInstance3D.new()
		mesh.mesh = batches[mat].commit()
		mesh.material_override = mat
		add_child(mesh)


func material(hex: String) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = preload("res://world/lourizan_architecture.gdshader")
	result.set_shader_parameter("paint", Color(hex))
	return result


func piece(mesh: Mesh, at: Vector3, mat: Material) -> void:
	if not batches.has(mat):
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		batches[mat] = surface
	batches[mat].append_from(
		mesh,
		0,
		Transform3D(
			Basis.IDENTITY.scaled(Vector3.ONE * 0.65), island_origin + (at - island_origin) * 0.65
		)
	)


func box(at: Vector3, size: Vector3, mat: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	piece(mesh, at, mat)
