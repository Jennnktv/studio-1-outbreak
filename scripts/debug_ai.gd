extends Node2D

@onready var human: HumanController = $Human

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var target = get_global_mouse_position()
			human.navigator.target_position = target
			