shader_type spatial;
render_mode cull_disabled;

uniform vec3 color = vec3(0.3, 0.6, 0.1);
uniform vec3 backlight = vec3(0.2, 0.2, 0.2);
uniform float size = 0.5;
uniform float blade_blend = 0.5;
uniform float roughness = 0.4;
uniform float specular = 0.2;

varying float bottom_to_top;

void vertex() {
	bottom_to_top = 1.0 - UV.y;

	VERTEX.z = blade_blend * pow(bottom_to_top, 2.0);

	VERTEX *= size;
}

void fragment() {
	AO = bottom_to_top;
	AO_LIGHT_AFFECT = 1.0;

	BACKLIGHT = backlight;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	NORMAL = mix(NORMAL, vec3(0.0, 1.0, 0.0), bottom_to_top);

	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
