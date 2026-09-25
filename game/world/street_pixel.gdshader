shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;

void fragment() {
	float block = max(1.0, floor(1.0 / SCREEN_PIXEL_SIZE.y / 360.0));
	vec2 grid = SCREEN_PIXEL_SIZE * block;
	vec2 sample_uv = (floor(SCREEN_UV / grid) + 0.5) * grid;
	COLOR = vec4(textureLod(screen_texture, sample_uv, 0.0).rgb, 1.0);
}
