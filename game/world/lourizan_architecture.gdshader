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
 float light = 0.68 + 0.32 * max(dot(n, normalize(vec3(0.7, 1.0, 0.5))), 0.0);
 vec3 color = paint.rgb * light;
 vec3 p = floor(point * 12.0);
 float grain = fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
 color *= 0.99 + 0.02 * step(0.75, grain);
 if (pattern == 1) {
  float joint = fract(point.y * 2.5);
  color *= mix(0.86, 1.0, step(0.04, joint));
 }
 if (pattern == 2) {
  float row = floor(point.y * 5.0);
  float slate = fract((point.z + point.x) * 3.0 + mod(row, 2.0) * 0.5);
  color *= 0.85 + 0.15 * step(0.06, slate);
 }
 ALBEDO = color;
 ROUGHNESS = 1.0;
}
