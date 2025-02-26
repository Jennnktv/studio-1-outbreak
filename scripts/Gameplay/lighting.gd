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
	

func _update_light_radius(_value:float) -> void:
	#print(value)
	#print(_value)
	pass
