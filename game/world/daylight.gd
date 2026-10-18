extends Node
## Local device time grades the complete world, including its distant illustration.
## HUD layers are drawn afterwards and retain their original contrast.

@export_range(-1.0, 24.0) var preview_hour := -1.0
@export var screen_path := NodePath("Street/PixelPass/Screen")
var material: ShaderMaterial
var elapsed := 0.0
var daylight := 1.0


func _ready() -> void:
	var screen: ColorRect = get_parent().get_node(screen_path)
	material = screen.material.duplicate()
	screen.material = material
	_update_light()


func _process(delta: float) -> void:
	_update_pools()
	elapsed += delta
	if elapsed >= 1.0:
		elapsed = 0.0
		_update_light()


func _update_light() -> void:
	var hour := preview_hour
	if hour < 0.0:
		var local_time := Time.get_time_dict_from_system(false)
		hour = local_time.hour + local_time.minute / 60.0 + local_time.second / 3600.0
	# Approximate art cycle, not a simulation of geographical sunrise times.
	var sun := cos((hour - 13.0) * TAU / 24.0)
	daylight = smoothstep(-0.15, 0.25, sun)
	var twilight := 4.0 * daylight * (1.0 - daylight)
	material.set_shader_parameter("daylight", daylight)
	material.set_shader_parameter("twilight", twilight)

	get_parent().get_node("DreamCastles").material.set_shader_parameter("daylight", daylight)


func _update_pools() -> void:
	var world := get_parent()
	var camera: Camera3D = world.camera_rig.get_node("Camera")
	var viewport_size := get_viewport().get_visible_rect().size
	var indoors: bool = world.inside_salon or world.current_id == &"scandale"
	var pools := PackedVector4Array()
	var bulbs := PackedVector2Array()
	for source in get_tree().get_nodes_in_group("pixel_lights"):
		if source.place_id != world.current_id or source.indoors != indoors:
			continue
		if not source.is_visible_in_tree() or camera.is_position_behind(source.global_position):
			continue
		var strength: float = 1.0 if source.indoors else 1.0 - daylight
		var center: Vector2 = camera.unproject_position(source.global_position) / viewport_size
		var edge: Vector2 = (
			camera.unproject_position(
				source.global_position + camera.global_basis.x * source.radius
			)
			/ viewport_size
		)
		pools.append(Vector4(center.x, center.y, absf(edge.x - center.x), strength))
		bulbs.append(
			(
				camera.unproject_position(source.to_global(Vector3.UP * source.bulb_height))
				/ viewport_size
			)
		)
		if pools.size() == 8:
			break
	material.set_shader_parameter("light_count", pools.size())
	pools.resize(8)
	bulbs.resize(8)
	material.set_shader_parameter("light_pools", pools)
	material.set_shader_parameter("light_bulbs", bulbs)
	# The enclosed salon stays warmly lit even when its exterior is night.
	material.set_shader_parameter("indoors", indoors)
