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
 vec3 p = floor(point * 26.666667) / 26.666667;
 float diffuse = max(dot(normalize(normal_world), normalize(vec3(0.6,1.0,0.5))),0.0);
 float shade = 0.66 + 0.34 * floor(diffuse * 3.0) / 3.0;
 vec3 color = paint.rgb;
 if (pattern == 1) {
  vec2 tile = fract(p.xz / 0.45);
  float seam = max(step(0.93,tile.x),step(0.93,tile.y));
  float band = mod(floor(p.x/0.45)+floor(p.z/0.45)*3.0,4.0);
  color *= 0.86 + band * 0.045;
  color = mix(color,vec3(0.20,0.13,0.11),seam*0.7);
 }
 if (pattern == 2) {
  float grain = mod(floor(p.z * 13.3333) + floor(p.x * 2.0), 7.0);
  color *= grain < 1.0 ? 0.78 : (grain < 3.0 ? 0.92 : 1.0);
 }
 if (pattern == 3) {
  vec2 uv = floor(UV * vec2(64.0,64.0));
  vec2 cell = floor(uv / vec2(6.0,8.0));
  vec2 inside = mod(uv,vec2(6.0,8.0));
  float seed = mod(cell.x*7.0+cell.y*3.0,5.0);
  color = seed < 1.0 ? vec3(0.65,0.31,0.27) : (seed < 2.0 ? vec3(0.30,0.43,0.38) : (seed < 3.0 ? vec3(0.71,0.64,0.44) : vec3(0.22,0.23,0.24)));
  if (inside.x < 1.0 || inside.y < 1.0) color=vec3(0.11,0.12,0.13);
  if (inside.y > 5.0 && inside.y < 7.0 && inside.x > 2.0) color=vec3(0.77,0.73,0.60);
  if (inside.x > 2.0 && inside.x < 5.0 && inside.y > 1.0 && inside.y < 5.0) color*=1.32;
 }
 if (pattern == 4) {
  float square=mod(floor(UV.x*16.0)+floor(UV.y*12.0),3.0);
  color*=0.7+square*0.15;
 }
 ALBEDO=color*shade;
 ROUGHNESS=1.0;
}
