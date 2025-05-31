shader_type canvas_item;

render_mode unshaded;//, skip_vertex_transform;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform bool is_color_per_channel_enabled = false;
uniform vec2 target_resolution = vec2(512.0, 512.0);
const float colors_per_channel = 4.0;

void fragment() {
	vec2 uv = floor(SCREEN_UV * target_resolution) / target_resolution;
	vec3 color = texture(screen_texture, uv).rgb;
	if (is_color_per_channel_enabled){
		vec3 quantized_color = floor(color * colors_per_channel) / colors_per_channel;
		COLOR = vec4(quantized_color, 1.0);
	}
	else COLOR = vec4(color, 1.0);
}
