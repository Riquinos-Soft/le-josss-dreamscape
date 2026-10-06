@tool
extends Node3D
## Reusable metre-sized botanical billboard; original atlas with transparent gutters.

const HEIGHTS := [10.0, 14.0, 8.0, 3.0, 0.85]
const REGIONS := [
	Rect2(0, 0, 690, 670),
	Rect2(700, 0, 550, 670),
	Rect2(0, 675, 662, 550),
	Rect2(665, 675, 585, 550)
]

@export_enum("Cedar", "Metasequoia", "Magnolia", "Camellia", "Fern") var species := 0
var foliage_material: ShaderMaterial
var tracked_player: Node3D


func _ready() -> void:
	var visual := MeshInstance3D.new()
	var quad := QuadMesh.new()
	var height: float = HEIGHTS[species]
	quad.size = Vector2.ONE * height
	quad.center_offset = Vector3.UP * height * 0.42
	visual.mesh = quad
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/street_decor.gdshader")
	var texture_path := "res://assets/art/vegetation/lourizan_botanical_v01.png"
	var region: Rect2 = REGIONS[mini(species, 3)]
	var atlas_scale := region.size / 1254.0
	var atlas_offset := region.position / 1254.0
	if species < 4:
		quad.size.x = height * region.size.x / region.size.y
		var baseline := 643.0 if species < 2 else 1206.0
		quad.center_offset.y = height * ((baseline - region.position.y) / region.size.y - 0.5)
	if species == 4:
		texture_path = "res://assets/art/vegetation/plant_jacobo_woodland_v01.png"
		atlas_scale = Vector2(0.5, 0.5)
		atlas_offset = Vector2(0, 0.5)
	material.set_shader_parameter("art_texture", load(texture_path))
	material.set_shader_parameter("face_camera", true)
	material.set_shader_parameter("wall_fade", species < 3)
	foliage_material = material
	material.set_shader_parameter("atlas_scale", atlas_scale)
	material.set_shader_parameter("atlas_offset", atlas_offset)
	visual.material_override = material
	add_child(visual)
	if species < 3:
		var trunk := StaticBody3D.new()
		var collider := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.height = 1.5
		shape.radius = 0.32 if species != 1 else 0.42
		collider.shape = shape
		collider.position.y = 0.75
		trunk.add_child(collider)
		add_child(trunk)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or species >= 3:
		return
	if not is_instance_valid(tracked_player):
		var camera := get_viewport().get_camera_3d()
		if camera != null:
			tracked_player = camera.get_parent().get("target") as Node3D
	if is_instance_valid(tracked_player):
		foliage_material.set_shader_parameter("player_position", tracked_player.global_position)
