shader_type canvas_item;

void vertex() {
	//COLOR = vec4(UV.x,UV.y,0.0,1.0);
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(UV.x,UV.y,0.0,1.0);
}
