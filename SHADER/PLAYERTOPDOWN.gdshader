shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(0.14, 0.51, 0.38, 1.0);
uniform vec4 new_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float diff = distance(tex_color.rgb, target_color.rgb);
	
	if (diff < tolerance) {
		COLOR = vec4(new_color.rgb, tex_color.a * new_color.a);
	} else {
		COLOR = tex_color;
	}
}