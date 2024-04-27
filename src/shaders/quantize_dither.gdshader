//https://godotshaders.com/shader/retro-post-processing/
//https://godotshaders.com/shader/ps1-post-processing/

shader_type canvas_item;


uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform bool dithering = true;
uniform bool change_color_depth = true;
uniform int target_color_depth : hint_range(1, 8) = 5;


const int IndexMatrix(ivec2 fragCoord) {
	const int thresholdMap[] = {
		-4, +0, -3, +1, 
		+2, -2, +3, -1, 
		-3, +1, -4, +0, 
		+3, -1, +2, -2
	};
	int x = fragCoord.x % 4;
	int y = fragCoord.y % 4;
	
	return thresholdMap[x + y * 4];
}


void fragment() {
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 q = FRAGCOORD.xy / iResolution.xy;
	ivec2 uv = ivec2(q);
	
	vec3 color = texture(screen_texture, vec2(q.x,q.y) ).xyz;
	
	uv = ivec2(FRAGCOORD.xy);
	color = texelFetch(screen_texture, uv, 0).rgb;
	
	// Convert from [0.0, 1.0] range to [0, 255] range
	ivec3 c = ivec3(round(color * 255.0));
	
	// Apply the dithering pattern
	if (dithering) {
		c += ivec3(IndexMatrix(uv));
	}
	
	vec3 final_color;
	if (change_color_depth){
		// Truncate from 8 bits to color_depth bits
		c >>= (8 - target_color_depth);
		final_color = vec3(c) / float(1 << target_color_depth);
	} else {
		final_color = vec3(c) / float(1 << 8);
	}
	
	// Convert back to [0.0, 1.0] range
	COLOR.rgb = final_color;
}