shader_type spatial;

uniform vec4 cooldown_color : source_color = vec4(0.7, 0.7, 0.7, 0.4);
uniform vec4 ready_color    : source_color = vec4(0.0, 1.0, 1.0, 0.7);
uniform float progress : hint_range(0.0, 1.0);

void fragment() {
	// UV.x goes left (0) → right (1)
	float mask = step(UV.x, progress);
	vec4 color = mix(cooldown_color, ready_color, mask);
	ALBEDO = color.rgb;
	ALPHA = color.a;
}


//shader_type spatial;
//render_mode unshaded;
//
//uniform vec4 cooldown_color : source_color;
//uniform vec4 ready_color    : source_color;
//uniform float progress;
//
//void fragment() {
	//float x = clamp(UV.x, 0.0, 1.0);
	//float mask = step(x, progress);
	//ALBEDO = mix(cooldown_color.rgb, ready_color.rgb, mask);
	//ALPHA = 1.0;
//}
