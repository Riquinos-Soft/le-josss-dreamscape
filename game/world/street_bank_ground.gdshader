shader_type spatial;
render_mode unshaded, cull_disabled;

varying vec3 world_position;

float patch_hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = floor(world_position.xz * 10.0) / 10.0;
	vec2 cell = floor(p * 0.8);
	vec2 f = smoothstep(vec2(0.0), vec2(1.0), fract(p * 0.8));
	float patch = mix(mix(patch_hash(cell), patch_hash(cell + vec2(1.0, 0.0)), f.x),
		mix(patch_hash(cell + vec2(0.0, 1.0)), patch_hash(cell + vec2(1.0)), f.x), f.y);
	vec3 grass = mix(vec3(0.14, 0.23, 0.22), vec3(0.21, 0.29, 0.24), step(0.48, patch));
	grass = mix(grass, vec3(0.29, 0.32, 0.23), step(0.7, patch));
	float grain = patch_hash(floor(p * 10.0));
	if (grain > 0.95) { grass += vec3(0.045, 0.04, 0.01); }
	// Sparse exposed soil and a darker foot of the hedge; never change collision.
	if (UV.y > 0.88 && grain > 0.6) { grass = vec3(0.24, 0.23, 0.22); }
	float edge = floor(smoothstep(0.0, 0.25, UV.y) * 4.0) / 4.0;
	vec3 color = mix(vec3(0.12, 0.095, 0.18), grass, edge);
	ALBEDO = OUTPUT_IS_SRGB ? color : pow(color, vec3(2.2));
}
