class_name Lighting extends ColorRect

const base_band_radius:float = 100
var band_radius:float = 100
const base_light_radius:float = 256
var zoom_radius:float = 256

func _ready() -> void:
	show()
	SignalBus.current_stim.connect(_update_light_radius)
	SignalBus.camera_zoom_change.connect(_update_zoom_radius)
	
func _process(_delta:float) -> void:
	var light_positions:Array = _get_light_positions()
	material.set_shader_parameter("number_of_lights", light_positions.size())
	material.set_shader_parameter("lights", light_positions)
	
func _get_light_positions() -> Array:
	return get_tree().get_nodes_in_group("light").map(
		func(light: Node2D) -> Vector2:
			return light.get_global_transform_with_canvas().origin
	)

func _update_zoom_radius(value:float) -> void:
	zoom_radius = base_light_radius * value
	band_radius = base_band_radius * value
	material.set_shader_parameter("light_radius", zoom_radius)
	material.set_shader_parameter("band_radius", band_radius)
	

func _update_light_radius(target_radius:float) -> void:
	var current_light_radius = material.get_shader_parameter("light_radius")
	var current_band_radius = material.get_shader_parameter("band_radius")
	
	_animate_parameter("light_radius", current_light_radius, target_radius)
	_animate_parameter("band_radius", current_band_radius, target_radius)

func _animate_parameter(parameter_name: String, from_value: float = 0.0, to_value: float = 0.0) -> void:
	var tween = _create_custom_tween()
	tween.tween_method(
		func(value: float): material.set_shader_parameter(parameter_name, value), 
		from_value,
		to_value,
		1.0
	)

func _create_custom_tween() -> Tween:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	return tween
