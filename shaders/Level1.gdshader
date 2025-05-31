shader_type sky;

uniform vec3 skyColor : source_color;
uniform sampler2D skyTexture : filter_nearest, hint_default_transparent;

void sky() {
	float timeCycle = TIME - float(floor(TIME));
	//COLOR = skyColor;
	//COLOR = vec3(1, SCREEN_UV);
	COLOR = texture(skyTexture, SKY_COORDS * vec2(1, 42) + timeCycle).rgb;
}
