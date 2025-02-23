shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 lights[100];
uniform int number_of_lights = 1;
uniform vec4 modulate_color : source_color = vec4(0.0);
uniform float band_radius = 100.0;
uniform float band_strength = 0.3;
uniform vec4 black_point : source_color = vec4(0.0);
uniform float light_radius = 64.0;
uniform float darkness_alpha = 1;

float distance_to_light(vec2 coords) {
	float dist = 1000.0;
	for (int i = 0; i < number_of_lights; i++) {
		float new_dist = distance(coords, lights[i]);
		if (new_dist < dist) {
			dist = new_dist;
		}
	}
	
	return dist;
}

vec4 modulate(vec4 color, float _distance_to_light) {
	vec4 modulated = color * modulate_color;
	if (_distance_to_light > band_radius) {
		float alpha = min((_distance_to_light - band_radius)/light_radius, darkness_alpha);
		return vec4(0, 0, 0, alpha);
	}
	//if (_distance_to_light > light_radius) {
		//float alpha = min(_distance_to_light/ light_radius, 0.7);
		//modulated.a = alpha;
		//return modulated;
	//}
	//else if (_distance_to_light >= band_radius) {
		////modulated.a = min(band_radius / _distance_to_light, 0.5);
		//float alpha = min(_distance_to_light / light_radius, 0.5);
		//return vec4(0,0,0,alpha);
		////return mix(color, modulated, band_strength);
	//}
	
	return color;
}

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR = modulate(COLOR, distance_to_light(FRAGCOORD.xy));
}