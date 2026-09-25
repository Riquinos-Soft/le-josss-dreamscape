shader_type spatial;
render_mode cull_disabled;

uniform vec3 route[15];
uniform float half_width = 1.35;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	// Remove only scanned ground under the authored pavement, keeping tall decoration.
	for (int i = 0; i < 14; i++) {
		vec2 segment = route[i + 1].xz - route[i].xz;
		float along = dot(world_position.xz - route[i].xz, segment) / dot(segment, segment);
		vec3 center = mix(route[i], route[i + 1], along);
		if (along >= 0.0 && along <= 1.0 && distance(world_position.xz, center.xz) < half_width && world_position.y < center.y + 0.30) {
			discard;
		}
	}
	vec3 cell = floor(world_position * 6.0);
	float noise = fract(sin(dot(cell, vec3(12.9898, 78.233, 34.52))) * 43758.5453);
	float tone = floor(noise * 3.0) / 2.0;
	vec3 stone = mix(vec3(0.30, 0.25, 0.39), vec3(0.43, 0.35, 0.43), tone);
	vec3 moss = mix(vec3(0.17, 0.27, 0.27), vec3(0.27, 0.35, 0.30), tone);
	float patch = sin(world_position.x * 2.0) * sin(world_position.z * 1.3);
	ALBEDO = mix(stone, moss, step(0.12, patch) * step(0.35, world_normal.y));
	ROUGHNESS = 1.0;
}
