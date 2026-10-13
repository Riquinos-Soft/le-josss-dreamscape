shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 paint : source_color = vec4(0.6, 0.55, 0.45, 1.0);
uniform int pattern = 0;
varying vec3 point;
varying vec3 normal_world;
void vertex() {
 point = VERTEX;
 normal_world = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
 vec3 n = normalize(normal_world);
 vec3 pixel_point = floor(point * 12.0) / 12.0;
 float diffuse = max(dot(n, normalize(vec3(0.7, 1.0, 0.5))), 0.0);
 float light = 0.64 + 0.36 * floor(diffuse * 4.0) / 4.0;
 vec3 color = paint.rgb * light;
 vec3 p = floor(point * 12.0);
 float grain = fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
 color *= 0.94 + 0.06 * step(0.4, grain) + 0.04 * step(0.88, grain);
 if (pattern == 1) {
  float joint = fract(pixel_point.y * 2.5);
  float row = floor(pixel_point.y * 2.5);
  float vertical = fract((pixel_point.x + pixel_point.z) * 0.9 + mod(row, 2.0) * 0.5);
  color *= mix(0.86, 1.0, step(0.035, joint) * step(0.012, vertical));
 }
 if (pattern == 2) {
  float row = floor(pixel_point.y * 5.0);
  float slate = fract((pixel_point.z + pixel_point.x) * 3.0 + mod(row, 2.0) * 0.5);
  color *= 0.85 + 0.15 * step(0.06, slate);
 }
 if (pattern == 3) {
  vec2 slab = vec2(pixel_point.x * 0.75, pixel_point.z * 0.9);
  slab.y += mod(floor(slab.x), 2.0) * 0.5;
  vec2 edge = fract(slab);
  float join = step(0.018, edge.x) * step(0.018, edge.y);
  float tone = fract(sin(dot(floor(slab), vec2(12.9898, 78.233))) * 43758.5453);
  color *= mix(0.74, 0.92 + tone * 0.14, join);
 }
 ALBEDO = color;
 ROUGHNESS = 1.0;
}
