shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;
// Beta comparison setting, not a project-wide asset resolution standard.
uniform float world_pixel_height : hint_range(90.0, 360.0) = 180.0;

void fragment() {
	float block = max(2.0, ceil(1.0 / SCREEN_PIXEL_SIZE.y / world_pixel_height));
	vec2 grid = SCREEN_PIXEL_SIZE * block;
	vec2 sample_uv = (floor(SCREEN_UV / grid) + 0.5) * grid;
	COLOR = vec4(textureLod(screen_texture, sample_uv, 0.0).rgb, 1.0);
}
