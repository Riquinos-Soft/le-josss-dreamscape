extends Node3D
## Small cigarette and smoke puffs, visible only during a guide's patrol pauses.

var smoke: CPUParticles3D
var cigarette: MeshInstance3D


func _ready() -> void:
	position = Vector3(0.16, 1.48, 0.08)
	cigarette = MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = 0.016
	shape.bottom_radius = 0.016
	shape.height = 0.16
	cigarette.mesh = shape
	cigarette.rotation.z = PI / 2
	var paper := StandardMaterial3D.new()
	paper.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paper.albedo_color = Color("ead6ab")
	cigarette.material_override = paper
	add_child(cigarette)
	smoke = CPUParticles3D.new()
	smoke.amount = 10
	smoke.lifetime = 2.0
	smoke.direction = Vector3.UP
	smoke.spread = 12.0
	smoke.gravity = Vector3(0.06, 0.12, 0)
	smoke.initial_velocity_min = 0.12
	smoke.initial_velocity_max = 0.25
	smoke.scale_amount_min = 0.6
	smoke.scale_amount_max = 1.1
	var puff := SphereMesh.new()
	puff.radius = 0.10
	puff.height = 0.20
	puff.radial_segments = 8
	puff.rings = 4
	var mist := StandardMaterial3D.new()
	mist.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mist.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist.albedo_color = Color(0.8, 0.8, 0.85, 0.45)
	puff.material = mist
	smoke.mesh = puff
	add_child(smoke)
	set_smoking(false)


func set_smoking(active: bool) -> void:
	cigarette.visible = active
	smoke.emitting = active
