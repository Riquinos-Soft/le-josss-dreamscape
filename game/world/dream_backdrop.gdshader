shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled;

uniform sampler2D illustration : source_color, filter_nearest, repeat_disable;

void vertex() {
	// Compatibility renderer: reversed-Z far depth is -1 in clip space.
	POSITION = vec4(VERTEX.xy, -1.0, 1.0);
}

void fragment() {
	vec2 image_size = vec2(textureSize(illustration, 0));
	float image_aspect = image_size.x / image_size.y;
	float view_aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	vec2 crop = vec2(min(1.0, view_aspect / image_aspect), min(1.0, image_aspect / view_aspect));
	vec2 uv = (SCREEN_UV - 0.5) * crop + 0.5;
	ALBEDO = texture(illustration, uv).rgb;
}
