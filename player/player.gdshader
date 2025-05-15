shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const vec3 DARK = vec3(7.0/255.0, 24.0/255.0, 33.0/255.0);
const vec3 HOLE = vec3(1.0, 0.0, 1.0);

const vec4 TRANSPARENT = vec4(0.0, 0.0, 0.0, 0.0);

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 1.0);
	if (c.rgb == HOLE) {
		COLOR = TRANSPARENT;
	} else {
		COLOR = c;
	}

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
