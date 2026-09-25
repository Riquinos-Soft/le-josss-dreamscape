shader_type spatial;
render_mode unshaded, cull_disabled;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 grain = floor(world_position.xz * 32.0);
	float tone = fract(sin(dot(grain, vec2(12.9898, 78.233))) * 43758.5453);
	// Subtle asphalt grain; no invented paving joints or cobbles.
	vec3 asphalt = mix(vec3(0.13, 0.145, 0.18), vec3(0.17, 0.18, 0.22), step(0.7, tone));
	// The garage's original pale concrete apron is distinct from the road asphalt.
	if (world_position.z > 23.4 && world_position.z < 27.4 && world_position.x > -3.2) {
		asphalt = mix(vec3(0.33, 0.32, 0.37), vec3(0.37, 0.36, 0.40), step(0.78, tone));
	}
	ALBEDO = OUTPUT_IS_SRGB ? asphalt : pow(asphalt, vec3(2.2));
	ROUGHNESS = 1.0;
}
