shader_type canvas_item;
render_mode unshaded;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float distortion_factor;
uniform float distortion_speed;
uniform sampler2D noise_tex_1 : repeat_enable;
uniform sampler2D noise_tex_2 : repeat_enable;

void fragment() {
	vec2 noise_uv_1 = UV + TIME * distortion_speed;
	vec2 noise_uv_2 = UV - TIME * distortion_speed + vec2(0.2, 0.3);
	vec2 noise_1 = vec2(texture(noise_tex_1, noise_uv_1).r, texture(noise_tex_2, noise_uv_1).r);
	vec2 noise_2 = vec2(texture(noise_tex_1, noise_uv_2).r, texture(noise_tex_2, noise_uv_2).r);
	vec2 base_uv = UV + (noise_1 + noise_2) * distortion_factor - vec2(distortion_factor, distortion_factor);
	COLOR = texture(SCREEN_TEXTURE, base_uv, 1.0).rgba;
}