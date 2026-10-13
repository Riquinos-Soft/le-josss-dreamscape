shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled;

uniform sampler2D illustration : source_color, filter_nearest, repeat_disable;

uniform float daylight = 1.0;

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
	vec3 original = texture(illustration, uv).rgb;
	// Restrict sky treatment to the open upper sky; retain the painted islands.
	float sky = smoothstep(0.27, 0.48, dot(original, vec3(0.299, 0.587, 0.114)));
	sky *= 1.0 - smoothstep(0.23, 0.53, uv.y);
	vec3 day_sky = mix(vec3(0.44, 0.66, 0.78), vec3(0.79, 0.84, 0.77), uv.y * 2.0);
	vec3 day = mix(original * vec3(1.12, 1.15, 1.05), day_sky, sky * 0.88);
	vec3 night = mix(original * vec3(0.42, 0.48, 0.68), vec3(0.055, 0.08, 0.18), sky * 0.85);
	vec2 pixel = floor(uv * vec2(480.0, 270.0));
	float random = fract(sin(dot(pixel, vec2(127.1, 311.7))) * 43758.5453);
	float star = step(0.995, random) * step(0.55, sky);
	night += star * vec3(0.90, 0.91, 0.76);
	ALBEDO = mix(night, day, daylight);
}
