class_name Lighting extends ColorRect

func _ready() -> void:
	show()
	SignalBus.current_stim.connect(_update_light_radius)
	
func _process(_delta:float) -> void:
	var light_positions:Array = _get_light_positions()
	material.set_shader_parameter("number_of_lights", light_positions.size())
	material.set_shader_parameter("lights", light_positions)
	
func _get_light_positions() -> Array:
	return get_tree().get_nodes_in_group("light").map(
		func(light: Node2D) -> Vector2:
			return light.get_global_transform_with_canvas().origin
	)

func _update_light_radius(_value:float) -> void:
	pass
	#print(value)
