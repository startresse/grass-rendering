shader_type spatial;
render_mode cull_disabled;

// COLOR
uniform vec3 color_small: source_color = vec3(0.3, 0.6, 0.1);
uniform vec3 color_large: source_color = vec3(0.9, 0.9, 0.2);
uniform vec3 backlight: source_color = vec3(0.2, 0.2, 0.2);

// GRASS BENDING
uniform float size_small = 0.2;
uniform float size_large = 0.6;
uniform float blade_bend = 0.5;
varying float bottom_to_top;

// LIGHTING
uniform float roughness = 0.4;
uniform float specular = 0.2;

// PATCH
uniform sampler2D patch_noise;
uniform float patch_scale = 5.0;
varying float patch_factor;

// WIND
uniform sampler2D wind_noise;
uniform float wind_strength = 0.1;
uniform vec2 wind_direction = vec2(1.0, 0.0);
uniform float wind_ao_effect = 1.0;
varying float current_wind_bend;

void vertex() {
	patch_factor = texture(patch_noise, NODE_POSITION_WORLD.xz / patch_scale).r;

	bottom_to_top = 1.0 - UV.y;
	vec2 wind_position = NODE_POSITION_WORLD.xz / 10.0;
	wind_position -= TIME * wind_direction * wind_strength;
	current_wind_bend = texture(wind_noise, wind_position).x;
	current_wind_bend *= wind_strength;
	current_wind_bend *= bottom_to_top * 2.0;
	
	mat4 inv_model = inverse(MODEL_MATRIX);
	vec2 local_direction = (inv_model * vec4(wind_direction.x, 0.0, wind_direction.y, 0.0)).xz;
 	VERTEX.xz += current_wind_bend * local_direction;

	VERTEX.z = blade_bend * pow(bottom_to_top, 2.0);
	VERTEX *= mix(size_small, size_large, patch_factor);
}

void fragment() {
	AO = bottom_to_top - current_wind_bend * wind_ao_effect;
	AO_LIGHT_AFFECT = 1.0;

	BACKLIGHT = backlight;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	NORMAL = mix(NORMAL, vec3(0.0, 1.0, 0.0), bottom_to_top);
	if (!FRONT_FACING) NORMAL = -NORMAL;

	ALBEDO = mix(color_small, color_large, patch_factor);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
