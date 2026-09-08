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
	shape.size = Definition.SIZE
	collision.shape = shape
	add_child(collision)
	add_child(make_visual(Color(0.85, 0.35, 0.8)))


static func make_visual(color: Color) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	var mesh := BoxMesh.new()
	mesh.size = Definition.SIZE
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	visual.material_override = material
	# Off-center stripe makes all four yaw orientations readable.
	var marker := MeshInstance3D.new()
	var stripe := BoxMesh.new()
	stripe.size = Vector3(0.12, 0.015, 0.35)
	marker.mesh = stripe
	marker.position = Vector3(0.22, 0.255, 0)
	var ink := StandardMaterial3D.new()
	ink.albedo_color = Color(0.12, 0.12, 0.2)
	marker.material_override = ink
	visual.add_child(marker)
	return visual
