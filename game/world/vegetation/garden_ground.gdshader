shader_type spatial;
render_mode unshaded;
uniform bool gravel = false;
uniform float path_center_x = 0.0;
uniform float path_half_width = 7.5;
varying vec3 local_point;
float hash(vec2 p) {
 return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float patches(vec2 p) {
 vec2 cell = floor(p);
 vec2 f = smoothstep(vec2(0.0), vec2(1.0), fract(p));
 return mix(mix(hash(cell), hash(cell + vec2(1, 0)), f.x),
            mix(hash(cell + vec2(0, 1)), hash(cell + vec2(1, 1)), f.x), f.y);
}
void vertex() { local_point = VERTEX; }
void fragment() {
 vec2 p = local_point.xz;
 vec2 pixel = floor(p * 12.0);
 float grain = hash(pixel);
 float patch = patches(floor(p * 12.0) / 12.0 * 0.7);
 vec3 grass = mix(vec3(0.16, 0.23, 0.13), vec3(0.27, 0.34, 0.19), patch);
 grass += vec3(0.035, 0.035, 0.015) * step(0.77, grain);
 vec3 stone = mix(vec3(0.38, 0.38, 0.33), vec3(0.51, 0.49, 0.41), patch * 0.45 + grain * 0.55);
 // Small fixed aggregate and sparse fallen leaves, sampled in world-sized pixels.
 stone = mix(stone, vec3(0.60, 0.57, 0.46), step(0.975, grain));
 float edge = smoothstep(path_half_width * 0.64, path_half_width * 0.99, abs(p.x - path_center_x));
 if (gravel) {
  stone = mix(stone, grass, edge * step(0.35, patch));
 }
 vec3 color = gravel ? stone : grass;
 float litter = step(0.962, hash(floor(p * 6.0))) * step(0.4, patch);
 color = mix(color, vec3(0.39, 0.28, 0.13), litter * (gravel ? 0.6 : 0.8));
 ALBEDO = color;
 ROUGHNESS = 1.0;
}
