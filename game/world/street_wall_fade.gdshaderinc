// Continuous local alpha, shared by the captured and rebuilt walls. No dithering.
uniform vec3 player_position;
uniform bool wall_fade = true;

float wall_opacity(vec3 world_position, vec3 camera_position) {
	vec3 focus = player_position + vec3(0.0, 0.9, 0.0);
	vec3 ray = camera_position - focus;
	float along_view = dot(world_position - focus, ray) / max(dot(ray, ray), 0.001);
	float cover_distance = length(world_position - (focus + ray * along_view));
	if (!wall_fade || along_view <= 0.025 || along_view >= 1.0 || world_position.y <= player_position.y + 0.25) {
		return 1.0;
	}
	float reveal = 1.0 - smoothstep(0.8, 1.6, cover_distance);
	reveal *= smoothstep(0.25, 0.55, world_position.y - player_position.y);
	return mix(1.0, 0.12, reveal);
}
