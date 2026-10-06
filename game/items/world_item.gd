extends StaticBody3D
const Item = preload("res://items/item_instance.gd")
const Definition = preload("res://items/item_definition.gd")
var item: Item


func _init(value: Item) -> void:
	name = "WorldItem"
	item = value
	collision_layer = 4
	collision_mask = 0
	var collision := CollisionShape3D.new()
	collision.name = "Collision"
	var shape := BoxShape3D.new()
	shape.size = item.definition.size
	collision.shape = shape
	add_child(collision)
	add_child(make_visual(item.definition))


static func make_visual(definition: Definition, tint: Color = Color.WHITE) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	var body := CylinderMesh.new()
	body.top_radius = 0.055
	body.bottom_radius = 0.055
	body.height = 0.18
	body.radial_segments = 8
	visual.mesh = body
	visual.position.y = -0.06
	visual.material_override = make_material(Color("b85b12") * tint)
	visual.add_child(
		make_cylinder("Neck", 0.027, 0.11, Vector3(0, 0.115, 0), Color("d67a20") * tint)
	)
	visual.add_child(
		make_cylinder("Cap", 0.031, 0.016, Vector3(0, 0.178, 0), Color("159b9b") * tint)
	)
	var label := MeshInstance3D.new()
	label.name = "Label"
	var label_mesh := BoxMesh.new()
	label_mesh.size = Vector3(0.076, 0.072, 0.006)
	label.mesh = label_mesh
	label.position = Vector3(0, 0.0, -0.057)
	label.material_override = make_material(Color("f3ddb0") * tint)
	visual.add_child(label)
	var mark := MeshInstance3D.new()
	mark.name = "DreamMark"
	var mark_mesh := BoxMesh.new()
	mark_mesh.size = Vector3(0.026, 0.034, 0.004)
	mark.mesh = mark_mesh
	mark.position = Vector3(-0.012, 0, -0.006)
	mark.rotation.z = 0.45
	mark.material_override = make_material(Color("167f83") * tint)
	label.add_child(mark)
	var icon := Sprite3D.new()
	icon.name = "PixelIcon"
	icon.texture = definition.icon
	icon.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	icon.pixel_size = 0.00016
	icon.position = Vector3(0, 0.06, -0.012)
	icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	icon.modulate = tint
	visual.add_child(icon)
	var ring := MeshInstance3D.new()
	ring.name = "PickupRing"
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.11
	ring_mesh.outer_radius = 0.14
	ring_mesh.rings = 8
	ring_mesh.ring_segments = 12
	ring.mesh = ring_mesh
	ring.position.y = -0.089
	var ring_material := make_material(Color("54d9cb") * tint)
	ring_material.emission_enabled = true
	ring_material.emission = Color("238f8f") * tint
	ring.material_override = ring_material
	visual.add_child(ring)
	return visual


static func make_cylinder(
	part_name: String, radius: float, height: float, offset: Vector3, color: Color
) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	part.mesh = mesh
	part.position = offset
	part.material_override = make_material(color)
	return part


static func make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.65
	return material


static func tint_visual(root: MeshInstance3D, color: Color) -> void:
	for node in [
		root,
		root.get_node("Neck"),
		root.get_node("Cap"),
		root.get_node("Label"),
		root.get_node("PickupRing")
	]:
		node.material_override = make_material(color)
	root.get_node("Label/DreamMark").material_override = make_material(color)
	root.get_node("PixelIcon").modulate = color
