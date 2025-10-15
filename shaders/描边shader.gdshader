shader_type canvas_item;
uniform float outline_width = 1.0;
uniform vec4 outline_color : source_color = vec4(1,1,1,1);
uniform bool show_line = false;
void fragment() {
	vec2 uv = UV;
	vec2 uv_up = uv + vec2(0,TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_down = uv - vec2(0,TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_left = uv + vec2(TEXTURE_PIXEL_SIZE.y,0) * outline_width;
	vec2 uv_rigth = uv - vec2(TEXTURE_PIXEL_SIZE.y,0) * outline_width;
	vec4 sampling_up = texture(TEXTURE,uv_up);
	vec4 sampling_down = texture(TEXTURE,uv_down);
	vec4 sampling_left = texture(TEXTURE,uv_left);
	vec4 sampling_rigth = texture(TEXTURE,uv_rigth);
	vec4 outline = sampling_up+sampling_down+sampling_left+sampling_rigth;
	outline.rgb = outline_color.rgb;
	vec4 original_color = texture(TEXTURE,UV);
	
	if (show_line)
	{
		if (original_color.a != 0.0) COLOR = original_color;
		else COLOR = outline;
	}
		
	
}