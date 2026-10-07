shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 paint : source_color;
uniform int pattern = 0;
varying vec3 point;
varying vec3 normal_world;
void vertex() {
 point = VERTEX;
 normal_world = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
 float light = 0.7 + 0.3 * max(dot(normalize(normal_world), normalize(vec3(0.6,1.0,0.5))), 0.0);
 vec3 color = paint.rgb * light;
 if (pattern == 1) {
  vec2 p = vec2(point.x + point.z, point.z - point.x) * 0.65;
  float tile = mod(floor(p.x) + floor(p.y), 2.0);
  color = mix(vec3(0.21,0.26,0.28), paint.rgb, tile) * light;
  float vein = sin(point.x * 8.0 + sin(point.z * 3.0) * 1.2);
  color *= 0.94 + 0.06 * smoothstep(-0.9, -0.6, vein);
 }
 if (pattern == 2) {
  vec2 cell = abs(fract(point.xz * vec2(0.8,0.6)) - 0.5);
  float ornament = step(0.34, cell.x + cell.y) * (1.0-step(0.40, cell.x + cell.y));
  color = mix(color, vec3(0.68,0.47,0.25), ornament * 0.7);
 }
 ALBEDO = color;
 ROUGHNESS = 1.0;
}
