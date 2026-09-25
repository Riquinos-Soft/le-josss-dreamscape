// A local pixel-stipple cutaway, shared by the captured and rebuilt walls.
uniform vec3 player_position;
uniform bool wall_fade = true;

bool hides_character(vec3 world_position, vec3 camera_position, vec2 fragment_pixel) {
	vec3 focus = player_position + vec3(0.0, 0.9, 0.0);
	vec3 ray = camera_position - focus;
	float along_view = dot(world_position - focus, ray) / dot(ray, ray);
	float cover_distance = length(world_position - (focus + ray * along_view));
	if (!wall_fade || along_view <= 0.025 || along_view >= 1.0 || world_position.y <= player_position.y + 0.25) {
		return false;
	}
	float opacity = smoothstep(0.85, 1.55, cover_distance);
	vec2 pixel = floor(fragment_pixel / 2.0);
	float stipple = mod(pixel.x + pixel.y * 2.0, 4.0) / 4.0;
	return stipple > max(0.05, opacity);
}
