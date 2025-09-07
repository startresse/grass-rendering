shader_type spatial;

uniform vec3 color_small: source_color = vec3(0.3, 0.6, 0.1);
uniform vec3 color_large: source_color = vec3(0.9, 0.9, 0.2);
uniform vec3 color_ground: source_color = vec3(1,1,1);

uniform sampler2D patch_noise;
uniform float patch_scale = 5.0;
uniform sampler2D high_frequency_noise;

varying vec3 world_vertex;
varying float normal_to_view;

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

}

void fragment() {
	normal_to_view = 1.0 - dot(VIEW, NORMAL);
	
	float patch_factor = texture(patch_noise, world_vertex.xz / patch_scale).r;
	patch_factor = mix(patch_factor, 1.0, normal_to_view * 0.4);
	
	float high_frequency_sample = texture(high_frequency_noise, world_vertex.xz / patch_scale).r;
	float spottiness = (1.0 - normal_to_view) * 0.5 - patch_factor * 0.2;
	float ground_factor = smoothstep(spottiness + 0.1, spottiness - 0.1, high_frequency_sample);
	
	ALBEDO = mix(color_small, color_large, patch_factor);
	ALBEDO = mix(ALBEDO, color_ground, ground_factor);
}