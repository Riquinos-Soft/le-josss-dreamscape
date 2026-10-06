shader_type spatial;
render_mode unshaded, cull_disabled;

varying vec3 world_position;

float cell_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 rows = world_position.xz * 2.4;
	rows.x += mod(floor(rows.y), 2.0) * 0.5;
	vec2 cell = floor(rows);
	vec2 within = fract(rows);
	float variant = cell_hash(cell);
	vec3 stone = vec3(0.28, 0.29, 0.34);
	if (variant > 0.22) { stone = vec3(0.35, 0.35, 0.39); }
	if (variant > 0.53) { stone = vec3(0.42, 0.40, 0.41); }
	if (variant > 0.82) { stone = vec3(0.51, 0.48, 0.46); }
	float seam = min(min(within.x, 1.0 - within.x), min(within.y, 1.0 - within.y));
	if (seam < 0.055) { stone = vec3(0.16, 0.18, 0.23); }
	ALBEDO = OUTPUT_IS_SRGB ? stone : pow(stone, vec3(2.2));
	ROUGHNESS = 1.0;
}
