shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

#include "res://world/street_wall_fade.gdshaderinc"

uniform sampler2D art_texture : source_color, filter_nearest, repeat_enable;
uniform bool face_camera = false;
uniform vec2 atlas_offset = vec2(0.0);
uniform vec2 atlas_scale = vec2(1.0);
varying vec3 world_position;

void vertex() {
	if (face_camera) {
		// Explicit billboarding keeps atlas foliage flat, with the same fade as walls.
		vec3 right = INV_VIEW_MATRIX[0].xyz;
		vec3 up = INV_VIEW_MATRIX[1].xyz;
		world_position = MODEL_MATRIX[3].xyz + right * VERTEX.x + up * VERTEX.y;
		POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world_position, 1.0);
	} else {
		world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	}
}

void fragment() {
	vec4 art = texture(art_texture, UV * atlas_scale + atlas_offset);
	if (art.a < 0.5) { discard; }
	ALBEDO = art.rgb;
	ALPHA = wall_opacity(world_position, CAMERA_POSITION_WORLD);
}
