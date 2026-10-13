extends Node3D
## Illustrated distant realm, drawn behind all playable geometry without collision.


func _ready() -> void:
	var backdrop := MeshInstance3D.new()
	backdrop.name = "IllustratedBackdrop"
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	backdrop.mesh = quad
	backdrop.extra_cull_margin = 16384.0
	backdrop.ignore_occlusion_culling = true
	backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/dream_backdrop.gdshader")
	material.set_shader_parameter(
		"illustration", preload("res://assets/art/backgrounds/dream_castles.png")
	)
	backdrop.material_override = material
	add_child(backdrop)
