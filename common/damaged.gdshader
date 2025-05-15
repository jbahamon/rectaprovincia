shader_type canvas_item;

void fragment() {
	if (int(floor(TIME * 60.0)) % 2 > 0) {
		COLOR.a = 0.0;
	}
}
