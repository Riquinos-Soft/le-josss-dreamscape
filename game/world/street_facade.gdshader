shader_type spatial;
render_mode unshaded, cull_disabled;

#include "res://world/street_wall_fade.gdshaderinc"

uniform sampler2D facade_texture : source_color, filter_nearest, repeat_disable;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (hides_character(world_position, CAMERA_POSITION_WORLD, FRAGCOORD.xy)) { discard; }
	vec3 paint = texture(facade_texture, UV).rgb;
	ALBEDO = paint * vec3(0.86, 0.84, 1.0);
}
