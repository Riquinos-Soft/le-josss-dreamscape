extends Node
## Local device time grades the complete world, including its distant illustration.
## HUD layers are drawn afterwards and retain their original contrast.

@export_range(-1.0, 24.0) var preview_hour := -1.0
var material: ShaderMaterial
var elapsed := 0.0


func _ready() -> void:
	var screen: ColorRect = get_parent().get_node("Street/PixelPass/Screen")
	material = screen.material.duplicate()
	screen.material = material
	_update_light()


func _process(delta: float) -> void:
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
	var daylight := smoothstep(-0.15, 0.25, sun)
	var twilight := 4.0 * daylight * (1.0 - daylight)
	material.set_shader_parameter("daylight", daylight)
	material.set_shader_parameter("twilight", twilight)
