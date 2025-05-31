shader_type sky;

uniform sampler2D noise_tex_1 : repeat_enable;
uniform sampler2D noise_tex_2 : repeat_enable;

uniform vec3 skyColor : source_color;
uniform sampler2D skyTexture : filter_nearest, hint_default_transparent;
uniform float darkness;
uniform float glitchness = 0.0;

void sky() {
	//float timeCycle = TIME - float(floor(TIME));
	//COLOR = skyColor;
	//COLOR = vec3(1, SCREEN_UV);
	//COLOR = texture(skyTexture, SKY_COORDS * vec2(16, 9) + timeCycle).rgb * darkness;
	
	vec2 noise_uv_1 = SKY_COORDS + TIME;
	vec2 noise_uv_2 = SKY_COORDS - TIME + vec2(0.2, 0.3);
	vec2 noise_1 = vec2(texture(noise_tex_1, noise_uv_1).r, texture(noise_tex_2, noise_uv_1).r);
	vec2 noise_2 = vec2(texture(noise_tex_1, noise_uv_2).r, texture(noise_tex_2, noise_uv_2).r);
	vec2 new_uv = 0.1 * SCREEN_UV + SKY_COORDS + (noise_1 + noise_2) * pow(glitchness, 11.5);
	COLOR = texture(skyTexture, new_uv * vec2(16, 9) + TIME).rgb * darkness * vec3(1.0, 1.0 - glitchness, 1.0 - glitchness);
}
