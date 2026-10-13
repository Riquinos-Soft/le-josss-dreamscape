shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;
// Zero preserves the authored detail and smooth subpixel movement.
// Nonzero values are retained for offline comparisons with the historical beta.
uniform float world_pixel_height : hint_range(0.0, 360.0) = 0.0;

uniform float daylight : hint_range(0.0, 1.0) = 1.0;
uniform float twilight : hint_range(0.0, 1.0) = 0.0;

uniform bool indoors = false;
uniform int light_count = 0;
uniform vec4 light_pools[8];
uniform vec2 light_bulbs[8];

void fragment() {
	vec2 sample_uv = SCREEN_UV;
	if (world_pixel_height > 0.0) {
		float block = max(2.0, ceil(1.0 / SCREEN_PIXEL_SIZE.y / world_pixel_height));
		vec2 grid = SCREEN_PIXEL_SIZE * block;
		sample_uv = (floor(SCREEN_UV / grid) + 0.5) * grid;
	}
	vec3 color = textureLod(screen_texture, sample_uv, 0.0).rgb;
	// One grade keeps the map and background in the same time of day.
	vec3 tint = mix(vec3(0.36, 0.46, 0.68), vec3(1.0), daylight);
	tint = mix(tint, tint * vec3(1.12, 0.94, 0.86), twilight * 0.45);
	if (indoors) { tint = vec3(0.92, 0.85, 0.72); }
	vec3 lit = color * tint;
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	for (int i = 0; i < light_count; i++) {
		vec4 source = light_pools[i];
		vec2 delta = (sample_uv - source.xy) * vec2(1.0, 1.7 / aspect);
		float pool = 1.0 - smoothstep(0.0, source.z, length(delta));
		pool = floor(pool * 16.0) / 16.0 * source.w;
		lit = mix(lit, color * vec3(1.12, 0.96, 0.65), pool * 0.85);
		vec2 bulb_delta = (sample_uv - light_bulbs[i]) * vec2(aspect, 1.0);
		float halo = 1.0 - smoothstep(0.0, 0.035, length(bulb_delta));
		float core = 1.0 - smoothstep(0.002, 0.009, length(bulb_delta));
		lit += vec3(1.0, 0.65, 0.24) * (halo * 0.14 + core * 0.7) * source.w;
	}
	COLOR = vec4(lit, 1.0);
}
