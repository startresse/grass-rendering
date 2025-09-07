shader_type spatial;
render_mode cull_disabled;

// FEATURES
uniform bool enable_grass_bending = true;
uniform bool enable_wind = true;
uniform bool enable_object_bending = true;
uniform bool enable_grass_cutting = true;

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
uniform float wind_speed = 0.1;
uniform vec2 wind_direction = vec2(1.0, 0.0);
uniform float wind_ao_effect = 1.0;
varying float current_wind_bend;

// OBJECT DISPLACEMENT
uniform float object_radius = 1.0;
uniform float object_displacement_strength = 1.0;
uniform vec3 object_position;

// GRASS CUTTING
uniform float cut_height = 0.5;
varying float cut_height_;

// LOD BLENDING
instance uniform float alpha = 1.0;

void vertex() {
	mat4 inv_model = inverse(MODEL_MATRIX);

	// Cutting
	cut_height_ = 1.0;
	if (enable_grass_cutting)
	{
		cut_height_ = (NODE_POSITION_WORLD.x > 0.0) ? 1.0 : cut_height;
		VERTEX.y = min(VERTEX.y, cut_height_);
		UV.y = max(UV.y, 1.0 - cut_height_);
	}

	bottom_to_top = 1.0 - UV.y;

	// Object bending
	float object_distance = distance(object_position, NODE_POSITION_WORLD);
	float bend_away_strength = object_displacement_strength * max(object_radius - object_distance, 0.0) / object_radius;
	vec2 bend_direction = normalize(object_position.xz - NODE_POSITION_WORLD.xz);
	if (enable_object_bending)
	{
		VERTEX.xz -= (inv_model * vec4(bend_direction.x, 0.0, bend_direction.y, 0.0)).xz
			* bend_away_strength * bottom_to_top;
		VERTEX.y -= bend_away_strength * bottom_to_top * 0.5;
	}

	// wind bending
	vec2 wind_position = NODE_POSITION_WORLD.xz / 10.0;
	wind_position -= TIME * wind_direction * wind_speed;
	current_wind_bend = texture(wind_noise, wind_position).x;
	current_wind_bend *= wind_strength;
	current_wind_bend *= bottom_to_top * 2.0;
	if (enable_wind)
	{
		vec2 local_direction = (inv_model * vec4(wind_direction.x, 0.0, wind_direction.y, 0.0)).xz;
		VERTEX.xz += current_wind_bend * local_direction;
	}

	if (enable_grass_bending)
	{
		VERTEX.z = blade_bend * pow(bottom_to_top, 2.0);
	}

	patch_factor = texture(patch_noise, NODE_POSITION_WORLD.xz / patch_scale).r;
	VERTEX *= mix(size_small, size_large, patch_factor);
}

void fragment() {
	AO = bottom_to_top;
	if (enable_wind)
	{
		AO -= current_wind_bend * wind_ao_effect;
	}

	BACKLIGHT = backlight;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	NORMAL = mix(NORMAL, vec3(0.0, 1.0, 0.0), mix(1.0, bottom_to_top, alpha + 0.2));
	if (!FRONT_FACING) NORMAL = -NORMAL;

	ALBEDO = mix(color_small, color_large, patch_factor);
	
	ALPHA = alpha;
	ALPHA_HASH_SCALE = 1.0;
	
	AO_LIGHT_AFFECT = mix(0.2, cut_height, alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
