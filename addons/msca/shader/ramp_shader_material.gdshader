shader_type canvas_item;
//render_mode unshaded;

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

// Automatic smoothing
// independent of geometry and perspective
vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size)
{
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	
	vec2 uv_pixels = uv / pixel_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor * pixel_size;
	
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

vec4 swap_color(vec4 color){
	const float EPSILON = 0.0001;
	vec4 original_colors[8] = vec4[8] (original_0, original_1, original_2, original_3, original_4, original_5, original_6, original_7);
	vec4 replace_colors[8] = vec4[8] (replace_0, replace_1, replace_2, replace_3, replace_4, replace_5, replace_6, replace_7);
	for (int i = 0; i < 8; i ++) {
		float dist = distance(color, original_colors[i]);
		if (dist <= precision + EPSILON){
			return replace_colors[i];
		}
	}
	return color;
}

void fragment() {
	COLOR = texturePointSmooth(TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	COLOR = swap_color(texture(TEXTURE, UV));
}
