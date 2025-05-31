shader_type spatial;
render_mode unshaded;

uniform bool is_posterization_enabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform int pixel_size = 8;

uniform vec4 level1 : source_color = vec4(0,0,0,1);
uniform vec4 level2 : source_color = vec4(0.5,0.5,0.5,1);
uniform vec4 level3 : source_color = vec4(1,1,1,1);
uniform vec4 level4 : source_color = vec4(1,1,1,1);

uniform float threshold1 	: hint_range(0.0,1.0) = .1;
uniform float threshold2 	: hint_range(0.0,1.0) = .4;
uniform float threshold3	: hint_range(0.0,1.0) = .6;

void vertex() {
	//1
}

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);
	
	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;
	
	ALBEDO = texture(SCREEN_TEXTURE, vec2(x, y) / VIEWPORT_SIZE).xyz;
	
	if (is_posterization_enabled == true){
		float rgb_avg = (ALBEDO.r + ALBEDO.g + ALBEDO.b)/3.0;
		if(rgb_avg < threshold1){
			ALBEDO = level1.rgb;
		}else if(rgb_avg < threshold2){
			ALBEDO = level2.rgb;
		}else if(rgb_avg < threshold3){
			ALBEDO = level3.rgb;
		}else{
			ALBEDO = level4.rgb;
		}
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
