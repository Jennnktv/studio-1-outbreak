extends Camera2D

# Helps with testing
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 0.9  # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1.1  # Zoom out   
			
		SignalBus.camera_zoom_change.emit(zoom.x) 
