shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

// The scan supplies silhouette and broad material regions; colors are painted in
// a small shared palette so the source photograph is no longer the final image.
#include "res://world/street_wall_fade.gdshaderinc"

uniform sampler2D source_texture : source_color, filter_nearest, repeat_disable;
varying vec3 world_position;
varying vec3 world_normal;

float hash_cell(vec2 cell) {
	return fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	// The physically supported court gets a clean authored stone surface below.
	if (world_position.x > 4.8 && world_position.x < 14.4 &&
		world_position.z > -19.2 && world_position.z < 9.6 &&
		world_position.y < 2.0) {
		discard;
	}
	vec2 texel = (floor(UV * 192.0) + 0.5) / 192.0;
	vec3 captured = texture(source_texture, texel).rgb;
	float lightness = dot(captured, vec3(0.3, 0.59, 0.11));
	float grain = hash_cell(floor(world_position.xz * 6.0));
	float shade = clamp(lightness * 4.0 + (grain - 0.5) * 0.28, 0.0, 3.99);
	vec3 paint = vec3(0.12, 0.13, 0.19);
	if (shade >= 1.0) { paint = vec3(0.29, 0.30, 0.36); }
	if (shade >= 2.0) { paint = vec3(0.49, 0.47, 0.48); }
	if (shade >= 3.0) { paint = vec3(0.69, 0.65, 0.61); }
	// Horizontal stone reads as warm paving; vertical stone keeps a cool facade.
	if (world_normal.y > 0.65) {
		paint *= vec3(0.96, 0.94, 0.88);
	} else {
		paint *= vec3(0.87, 0.91, 1.05);
	}
	float green = captured.g - max(captured.r * 0.94, captured.b * 1.06);
	if (green > 0.012) {
		paint = vec3(0.11, 0.18, 0.18);
		if (shade >= 1.0) { paint = vec3(0.19, 0.28, 0.23); }
		if (shade >= 2.0) { paint = vec3(0.31, 0.40, 0.27); }
		if (shade >= 3.0) { paint = vec3(0.48, 0.55, 0.35); }
	}
	if (world_position.y > 1.0 && world_normal.y < 0.55 && green <= 0.012) {
		vec2 face = vec2(world_position.x, world_position.y);
		if (abs(world_normal.x) > abs(world_normal.z)) { face.x = world_position.z; }
		face *= vec2(1.6, 2.4);
		face.x += mod(floor(face.y), 2.0) * 0.5;
		vec2 block = fract(face);
		float variant = hash_cell(floor(face));
		paint = vec3(0.35, 0.34, 0.40);
		if (variant > 0.34) { paint = vec3(0.45, 0.43, 0.46); }
		if (variant > 0.76) { paint = vec3(0.57, 0.54, 0.54); }
		if (min(min(block.x, 1.0 - block.x), min(block.y, 1.0 - block.y)) < 0.04) {
			paint *= 0.66;
		}
	}
	if (world_normal.y > 0.52 && green <= 0.012) {
		// World-aligned stone courses make the route read as authored paving even
		// when the captured UV atlas and triangle sizes vary wildly.
		vec2 course = world_position.xz * 2.6;
		course.x += mod(floor(course.y), 2.0) * 0.5;
		vec2 unit = fract(course);
		float tile = hash_cell(floor(course));
		paint = vec3(0.30, 0.30, 0.35);
		if (tile > 0.32) { paint = vec3(0.39, 0.39, 0.43); }
		if (tile > 0.70) { paint = vec3(0.50, 0.48, 0.48); }
		if (min(min(unit.x, 1.0 - unit.x), min(unit.y, 1.0 - unit.y)) < 0.065) {
			paint *= 0.55;
		}
	}
	ALBEDO = OUTPUT_IS_SRGB ? paint : pow(paint, vec3(2.2));
	ALPHA = wall_opacity(world_position, CAMERA_POSITION_WORLD);
	ROUGHNESS = 1.0;
}
