extends "res://world/home_exterior.gd"
## The captured Pazo keeps its geometry, with a small painted palette and reused plants.

const FOLIAGE = preload("res://assets/art/vegetation/plant_jacobo_atlas_v02.png")
const FOLIAGE_SHADER = preload("res://world/street_decor.gdshader")
const PIXEL_SHADER = preload("res://world/lourizan_pixel.gdshader")
const PAVING_SHADER = preload("res://world/lourizan_paving.gdshader")
const GROUND_SHADER = preload("res://world/street_bank_ground.gdshader")


func _ready() -> void:
	super()
	for visual in $CapturedExterior.find_children("*", "MeshInstance3D", true, false):
		var captured_material := visual.get_active_material(0) as StandardMaterial3D
		if captured_material == null or captured_material.albedo_texture == null:
			continue
		var painted := ShaderMaterial.new()
		painted.shader = PIXEL_SHADER
		painted.set_shader_parameter("source_texture", captured_material.albedo_texture)
		visual.material_override = painted
	add_ground_backdrop()
	add_paving_artwork()
	add_garden_accents()


func add_paving_artwork() -> void:
	var paving := MeshInstance3D.new()
	paving.name = "PixelPaving"
	var plane := PlaneMesh.new()
	plane.size = Vector2(8.0, 24.0) * place_scale
	paving.mesh = plane
	paving.position = $PavingSupport.position + Vector3.UP * (0.1 * place_scale + 0.006)
	var material := ShaderMaterial.new()
	material.shader = PAVING_SHADER
	paving.material_override = material
	add_child(paving)


func add_ground_backdrop() -> void:
	var backdrop := MeshInstance3D.new()
	backdrop.name = "PixelGroundBackdrop"
	var plane := PlaneMesh.new()
	plane.size = Vector2(38, 52) * place_scale
	backdrop.mesh = plane
	backdrop.position.y = -0.8 * place_scale
	var material := ShaderMaterial.new()
	material.shader = GROUND_SHADER
	backdrop.material_override = material
	add_child(backdrop)


func add_garden_accents() -> void:
	# These sit on the captured central bed; they add a few legible pixel silhouettes.
	var points := [
		Vector3(4.4, 0.75, -10.5),
		Vector3(4.2, 0.8, -6.0),
		Vector3(3.9, 0.75, -1.5),
	]
	for index in points.size():
		var material := ShaderMaterial.new()
		material.shader = FOLIAGE_SHADER
		material.set_shader_parameter("art_texture", FOLIAGE)
		material.set_shader_parameter("face_camera", true)
		material.set_shader_parameter("atlas_offset", Vector2(index % 2, index / 2) * 0.5)
		material.set_shader_parameter("atlas_scale", Vector2(0.5, 0.5))
		var quad := QuadMesh.new()
		quad.size = Vector2.ONE * 2.1
		quad.center_offset = Vector3.UP * 0.9
		var plant := MeshInstance3D.new()
		plant.name = "GardenAccent%d" % index
		plant.mesh = quad
		plant.position = points[index] * place_scale
		plant.material_override = material
		add_child(plant)
