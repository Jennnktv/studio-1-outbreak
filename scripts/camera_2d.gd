extends Camera2D

@export var min_zoom:Vector2 = Vector2(0.5,0.5)
@export var max_zoom:Vector2 = Vector2(1,1)

# Helps with testing
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 0.9  # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1.1  # Zoom out   
			
		zoom = clamp(zoom, min_zoom, max_zoom)
		SignalBus.camera_zoom_change.emit(zoom.x) 
