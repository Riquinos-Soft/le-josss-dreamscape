extends Area3D
## A local doorway between the terrace and its fictional dream salon.

signal passage_requested(passage: Area3D)

@export var destination: NodePath
@export var indoors := false
@export var caption := "Salón de los sueños"


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.9, 1.8, 1.7) if indoors else Vector3(2.0, 1.8, 0.9)
	shape.shape = box
	shape.position.y = 0.9
	add_child(shape)
	var label := Label3D.new()
	label.text = caption + "\nCamina para entrar" if indoors else caption + "\nCamina para salir"
	label.position.y = 2.5
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.012
	label.no_depth_test = true
	label.font_size = 28
	label.modulate = Color("eed3a0")
	label.outline_size = 8
	add_child(label)
	var threshold := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.8, 0.035, 1.65) if indoors else Vector3(1.95, 0.035, 0.8)
	threshold.mesh = mesh
	threshold.position.y = 0.035
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("c4a46f")
	threshold.material_override = material
	add_child(threshold)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.name == "Player":
		passage_requested.emit(self)
