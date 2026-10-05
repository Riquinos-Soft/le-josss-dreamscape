shader_type spatial;
render_mode unshaded, cull_disabled;

varying vec3 world_position;

float grain_hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float wear_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = smoothstep(vec2(0.0), vec2(1.0), fract(p));
	return mix(mix(grain_hash(cell), grain_hash(cell + vec2(1.0, 0.0)), f.x),
		mix(grain_hash(cell + vec2(0.0, 1.0)), grain_hash(cell + vec2(1.0)), f.x), f.y);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 grain = floor(world_position.xz * 8.0);
	float tone = grain_hash(grain);
	vec2 p = floor(world_position.xz * 12.0) / 12.0;
	float wear = wear_noise(p * 0.65);
	vec3 asphalt = mix(vec3(0.115, 0.115, 0.15), vec3(0.155, 0.15, 0.185), step(0.65, wear));
	asphalt += vec3(0.035) * step(0.86, tone);
	// Short, broken hairline repairs, rather than a regular paving grid.
	float crack = abs(p.x - (sin(floor(p.y * 2.0) * 0.7) * 0.18 + floor(p.x / 3.0) * 3.0 + 1.0));
	if (crack < 0.045 && grain_hash(floor(p / 2.0)) > 0.6) {
		asphalt *= 0.65;
	}
	// The footage shows dry leaves and moss concentrated beside the banks.
	float edge = min(UV.x, 1.0 - UV.x);
	if (edge < 0.13 && tone > 0.68 + edge) {
		asphalt = mix(vec3(0.24, 0.22, 0.20), vec3(0.36, 0.29, 0.20), step(0.87, tone));
	}
	if (edge < 0.055 && wear > 0.72 && tone < 0.5) {
		asphalt = vec3(0.18, 0.23, 0.19);
	}
	// The garage's original pale concrete apron is distinct from the road asphalt.
	if (world_position.z > 23.4 && world_position.z < 27.4 && world_position.x > -3.2) {
		asphalt = mix(vec3(0.33, 0.32, 0.37), vec3(0.37, 0.36, 0.40), step(0.78, tone));
	}
	ALBEDO = OUTPUT_IS_SRGB ? asphalt : pow(asphalt, vec3(2.2));
	ROUGHNESS = 1.0;
}
