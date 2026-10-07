shader_type spatial;
render_mode unshaded, cull_disabled;
void fragment() {
 vec2 p = UV * 90.0;
 float cloud = sin(p.x * 0.37 + sin(p.y * 0.23)) * sin(p.y * 0.21 + p.x * 0.11);
 vec3 color = mix(vec3(0.026,0.035,0.09), vec3(0.18,0.13,0.31), smoothstep(-0.4,0.8,cloud));
 vec2 cell = floor(p * 5.0);
 float seed = fract(sin(dot(cell, vec2(127.1,311.7))) * 43758.5453);
 vec2 dot_pos = fract(p * 5.0) - 0.5;
 float star = (1.0-smoothstep(0.01,0.065,length(dot_pos))) * step(0.96, seed);
 color += vec3(0.70,0.68,0.85) * star * (0.75 + 0.25*sin(TIME*0.6 + seed*60.0));
 ALBEDO = color;
}
