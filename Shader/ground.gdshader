shader_type spatial;

uniform vec3 color_small: source_color = vec3(0.3, 0.6, 0.1);
uniform vec3 color_large: source_color = vec3(0.9, 0.9, 0.2);
uniform vec3 color_ground: source_color = vec3(1,1,1);

uniform sampler2D patch_noise;
uniform float patch_scale = 5.0;
uniform sampler2D high_frequency_noise;

// WIND
uniform sampler2D wind_noise;
uniform float wind_strength = 0.1;
uniform float wind_speed = 0.1;
uniform vec2 wind_direction = vec2(1.0, 0.0);
uniform float wind_ao_effect = 1.0;

uniform sampler2D baked_normals;

varying vec3 world_vertex;
varying float normal_to_view;

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	NORMAL_MAP = texture(baked_normals, world_vertex.xz / 5.0, -3.0).xyz;
	
	normal_to_view = 1.0 - dot(VIEW, NORMAL);
	
	vec2 wind_position = world_vertex.xz / 10.0;
	wind_position -= (TIME + 8.0) * wind_direction * wind_speed;
	float current_wind_bend = texture(wind_noise, wind_position).x;
	current_wind_bend *= wind_strength;
	
	float patch_factor = texture(patch_noise, world_vertex.xz / patch_scale).r;
	patch_factor = mix(patch_factor, 1.0, normal_to_view * 0.4);
	
	float high_frequency_sample = texture(high_frequency_noise, world_vertex.xz / patch_scale, -3.0).r;
	float spottiness = (1.0 - normal_to_view) * 0.5 - patch_factor * 0.2;
	float ground_factor = smoothstep(spottiness + 0.1, spottiness - 0.1, high_frequency_sample);
	
	ALBEDO = mix(color_small, color_large, patch_factor);
	ALBEDO = mix(ALBEDO, color_ground, ground_factor);
	
	float bottom_to_top_simulation = high_frequency_sample + smoothstep(0.6, 1.0, normal_to_view) * 0.4;
	AO = mix(0.5, 1.0, bottom_to_top_simulation) - current_wind_bend * wind_ao_effect;
	AO_LIGHT_AFFECT = 1.0;
	
	BACKLIGHT = vec3(0.2);
	ROUGHNESS = 0.4;
	SPECULAR = 0.12;
}