shader_type spatial;
render_mode cull_disabled;

uniform float size = 0.5;
uniform float blade_blend = 0.5;

varying float bottom_to_top;

void vertex() {
	bottom_to_top = 1.0 - UV.y;
	
	VERTEX.z = blade_blend * pow(bottom_to_top, 2.0);
	
	VERTEX *= size;
}

void fragment() {
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
