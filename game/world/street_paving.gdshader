shader_type spatial;
render_mode cull_disabled;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 pixel = floor(world_position.xz * 24.0) / 24.0;
	float row = floor(pixel.y * 2.5);
	vec2 grid = vec2(pixel.x * 2.0 + mod(row, 2.0) * 0.5, pixel.y * 2.5);
	vec2 cell = floor(grid);
	vec2 edge = fract(grid);
	float tone = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
	tone = floor(tone * 4.0) / 3.0;
	vec3 stone = mix(vec3(0.32, 0.27, 0.39), vec3(0.48, 0.38, 0.44), tone);
	float grout = step(0.12, edge.x) * step(0.12, edge.y);
	ALBEDO = mix(vec3(0.12, 0.10, 0.20), stone, grout);
	ROUGHNESS = 1.0;
}
