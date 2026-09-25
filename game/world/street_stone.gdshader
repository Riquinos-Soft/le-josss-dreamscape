shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec3 route[15];
uniform vec3 walk_sections[34];
#include "res://world/street_wall_fade.gdshaderinc"

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	if (hides_character(world_position, CAMERA_POSITION_WORLD, FRAGCOORD.xy)) { discard; }
	for (int i = 0; i < 16; i++) {
		vec3 left_a = walk_sections[i * 2];
		vec3 left_b = walk_sections[i * 2 + 2];
		float along = (world_position.z - left_a.z) / (left_b.z - left_a.z);
		if (along >= 0.0 && along <= 1.0) {
			vec3 west = mix(left_a, left_b, along);
			vec3 east = mix(walk_sections[i * 2 + 1], walk_sections[i * 2 + 3], along);
			float across = (world_position.x - west.x) / (east.x - west.x);
			float floor_height = mix(west.y, east.y, across);
			if (across >= 0.0 && across <= 1.0 && world_position.y < floor_height + 0.20) { discard; }
		}
	}
	// The two garage faces are rebuilt at the surveyed footprint with pixel artwork.
	if (world_position.z > 16.0 && world_position.z < 24.6 && world_position.x > -2.3 && world_position.x < 4.5 && world_position.y > 1.1) { discard; }
	// Photograph sampled before mesh simplification: keep facade, door and plants.
	vec3 captured = max(COLOR.rgb, vec3(0.0));
	vec3 display_color = pow(captured, vec3(1.0 / 2.2));
	vec3 palette = floor(display_color * 16.0 + 0.5) / 16.0;
	// Flat painted tones, avoiding the scan's faceted dynamic lighting.
	vec3 tint = mix(vec3(0.73, 0.72, 0.94), vec3(1.0, 0.92, 0.80), step(0.45, world_normal.y));
	vec3 final_color = palette * tint;
	for (int i = 0; i < 14; i++) {
		vec2 segment = route[i + 1].xz - route[i].xz;
		float along = clamp(dot(world_position.xz - route[i].xz, segment) / dot(segment, segment), 0.0, 1.0);
		vec3 center = mix(route[i], route[i + 1], along);
		if (distance(world_position.xz, center.xz) < 1.55 && abs(world_position.y - center.y) < 0.4 && world_normal.y > 0.45) {
			float shade = dot(display_color, vec3(0.299, 0.587, 0.114));
			final_color = mix(vec3(0.10, 0.115, 0.15), vec3(0.21, 0.225, 0.27), shade);
		}
	}
	ALBEDO = OUTPUT_IS_SRGB ? final_color : pow(final_color, vec3(2.2));
	ROUGHNESS = 1.0;
}
