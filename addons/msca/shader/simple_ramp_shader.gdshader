shader_type canvas_item;

uniform vec4 original_0: source_color;
uniform vec4 original_1: source_color;
uniform vec4 original_2: source_color;
uniform vec4 original_3: source_color;
uniform vec4 original_4: source_color;
uniform vec4 original_5: source_color;
uniform vec4 original_6: source_color;
uniform vec4 original_7: source_color;
uniform vec4 replace_0: source_color;
uniform vec4 replace_1: source_color;
uniform vec4 replace_2: source_color;
uniform vec4 replace_3: source_color;
uniform vec4 replace_4: source_color;
uniform vec4 replace_5: source_color;
uniform vec4 replace_6: source_color;
uniform vec4 replace_7: source_color;

const float precision = 0.1;

vec4 swap_color(vec4 color){
	const float EPSILON = 0.0001;
	vec4 original_colors[8] = vec4[8] (original_0, original_1, original_2, original_3, original_4, original_5, original_6, original_7);
	vec4 replace_colors[8] = vec4[8] (replace_0, replace_1, replace_2, replace_3, replace_4, replace_5, replace_6, replace_7);
	for (int i = 0; i < 8; i ++) {
		//float dist = distance(color, original_colors[i]);
		//if (dist <= precision + EPSILON){
		//	return replace_colors[i];
		//}
		if (
			color.r >= original_colors[i].r - 0.001 && color.r <= original_colors[i].r + 0.001 &&
			color.g >= original_colors[i].g - 0.001 && color.g <= original_colors[i].g + 0.001 &&
			color.b >= original_colors[i].b - 0.001 && color.b <= original_colors[i].b + 0.001 &&
			color.a >= original_colors[i].a - 0.001 && color.a <= original_colors[i].a + 0.001
		){
			return replace_colors[i];
		}
	}
	return color;
}

void fragment() {
	//COLOR = swap_color(texture(TEXTURE, UV));
	COLOR = swap_color(COLOR);
}
