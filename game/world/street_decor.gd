extends Node3D
## Authored pixel scenery follows the surveyed banks; it does not own collision.

const FOLIAGE = preload("res://assets/art/vegetation/plant_jacobo_atlas_v02.png")
const WOODLAND = preload("res://assets/art/vegetation/plant_jacobo_woodland_v01.png")
const WALL = preload("res://assets/art/environments/wall_jacobo_stone_v02.svg")
const MATERIAL = preload("res://world/street_decor.gdshader")
const HEIGHTS: Array[float] = [
	0.55, 0.7, 0.8, 0.85, 0.8, 1.0, 1.1, 0.9, 0.8, 0.7, 0.6, 0.65, 0.6, 0.45, 0.5, 0.55, 0.5
]

var sections: Array[Vector3] = []
var fade_materials: Array[ShaderMaterial] = []
var foliage_materials: Array[ShaderMaterial] = []
var woodland_materials: Array[ShaderMaterial] = []


func _ready() -> void:
	var wall_material := make_material(WALL)
	for variant in 4:
		var material := make_material(FOLIAGE, true)
		material.set_shader_parameter("atlas_offset", Vector2(variant % 2, variant / 2) * 0.5)
		material.set_shader_parameter("atlas_scale", Vector2(0.5, 0.5))
		foliage_materials.append(material)
	for variant in 4:
		var material := make_material(WOODLAND, true)
		material.set_shader_parameter("atlas_offset", Vector2(variant % 2, variant / 2) * 0.5)
		material.set_shader_parameter("atlas_scale", Vector2(0.5, 0.5))
		woodland_materials.append(material)
	for side in 2:
		var outward := Vector3(-1 if side == 0 else 1, 0, 0)
		for index in 16:
			# The garage facade and its apron occupy this side, not a hedge barrier.
			if side == 1 and index in [9, 10, 11, 12]:
				continue
			var start := sections[index * 2 + side]
			var end := sections[index * 2 + side + 2]
			var height := HEIGHTS[index] * (1.0 if side == 0 else 0.7)
			add_bank(start, end, outward, height, wall_material)
			var count := maxi(1, ceili(start.distance_to(end) / 1.7))
			for plant in count:
				var along := (plant + 0.5) / count
				var position := start.lerp(end, along) + outward * (0.5 + 0.2 * (plant % 2))
				position.y += height - 0.08
				if (index + plant) % 3 != 0:
					add_woodland(position, 2 if side == 0 else 3, 0.045)
				else:
					add_foliage(position, 3 if side == 0 else 0, 0.045)
	# Footage 55-85s: mesh fence and tree canopy on the garage side of the lane.
	var fence_material := ShaderMaterial.new()
	fence_material.shader = preload("res://world/street_fence.gdshader")
	fade_materials.append(fence_material)
	for index in range(5, 10):
		add_fence(sections[index * 2 + 1], sections[index * 2 + 3], fence_material)
	for index in [5, 7, 9]:
		var base := sections[index * 2 + 1] + Vector3(0.95, HEIGHTS[index] * 0.7, 0)
		add_woodland(base, 0 if index != 7 else 1, 0.09)
	# A smaller tree opposite the garage, with its trunk safely outside the road.
	add_woodland(sections[22] + Vector3(-0.95, HEIGHTS[11], 0), 1, 0.075)
	# Ivy stays on the original garage face; the door apron stays clear.
	add_foliage(Vector3(-0.1, 2.85, 17.2), 2, 0.025)
	add_foliage(Vector3(-1.35, 2.4, 22.5), 2, 0.025)


func make_material(texture: Texture2D, billboard: bool = false) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = MATERIAL
	material.set_shader_parameter("art_texture", texture)
	material.set_shader_parameter("face_camera", billboard)
	fade_materials.append(material)
	return material


func add_foliage(base: Vector3, variant: int, pixel_size: float) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * 64.0 * pixel_size
	quad.center_offset = Vector3.UP * 28.0 * pixel_size
	var plant := MeshInstance3D.new()
	plant.name = "Foliage"
	plant.mesh = quad
	plant.position = base
	plant.material_override = foliage_materials[variant]
	add_child(plant)


func add_woodland(base: Vector3, variant: int, pixel_size: float) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * 64.0 * pixel_size
	quad.center_offset = Vector3.UP * 28.0 * pixel_size
	var plant := MeshInstance3D.new()
	plant.name = "Tree" if variant < 2 else "WildPlant"
	plant.mesh = quad
	plant.position = base
	plant.material_override = woodland_materials[variant]
	add_child(plant)


func add_fence(start: Vector3, end: Vector3, material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := start + Vector3(0.12, 0.65, 0)
	var b := end + Vector3(0.12, 0.65, 0)
	add_quad(
		surface,
		[a, a + Vector3.UP * 1.35, b, b + Vector3.UP * 1.35],
		Vector2(a.distance_to(b), 1.35)
	)
	surface.generate_normals()
	var fence := MeshInstance3D.new()
	fence.name = "LateralFence"
	fence.mesh = surface.commit()
	fence.material_override = material
	add_child(fence)


func add_bank(
	start: Vector3, end: Vector3, outward: Vector3, height: float, material: Material
) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := start + outward * 0.06
	var b := end + outward * 0.06
	var top_a := a + Vector3.UP * height
	var top_b := b + Vector3.UP * height
	var length := a.distance_to(b)
	add_quad(surface, [a, top_a, b, top_b], Vector2(length, height) / 1.8)
	add_quad(
		surface,
		[top_a, top_a + outward * 1.3, top_b, top_b + outward * 1.3],
		Vector2(length, 1.3) / 1.8
	)
	surface.generate_normals()
	var bank := MeshInstance3D.new()
	bank.name = "RetainingWall"
	bank.mesh = surface.commit()
	bank.material_override = material
	add_child(bank)


func add_quad(surface: SurfaceTool, corners: Array, repeat: Vector2) -> void:
	var uvs := [Vector2(0, 1), Vector2.ZERO, Vector2.ONE, Vector2(1, 0)]
	for index in [0, 1, 2, 2, 1, 3]:
		surface.set_uv(uvs[index] * repeat)
		surface.add_vertex(corners[index])
