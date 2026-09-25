shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

#include "res://world/street_wall_fade.gdshaderinc"
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Physical holes in chain-link mesh, not a stippled occlusion effect.
	vec2 p = floor(UV * 32.0) / 32.0;
	float diagonal = min(fract((p.x + p.y) * 3.0), fract((p.x - p.y) * 3.0));
	bool post = mod(p.x, 2.0) < 0.075;
	bool rail = p.y < 0.065 || p.y > 1.28;
	if (!post && !rail && diagonal > 0.12) { discard; }
	ALBEDO = post || rail ? vec3(0.24, 0.25, 0.29) : vec3(0.38, 0.40, 0.43);
	ALPHA = wall_opacity(world_position, CAMERA_POSITION_WORLD);
}
