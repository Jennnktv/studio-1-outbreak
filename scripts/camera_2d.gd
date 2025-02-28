extends Camera2D

@export var min_zoom:Vector2 = Vector2(0.5,0.5)
@export var max_zoom:Vector2 = Vector2(1,1)

@export var toggle_zoom_clamp := false
@onready var light_canvas = $"../../CanvasLayer"

# Helps with testing
func _unhandled_input(event):
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_L:
			if toggle_zoom_clamp:
				toggle_zoom_clamp = false
				light_canvas.visible = true
			else:
				toggle_zoom_clamp = true
				light_canvas.visible = false

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 0.9  # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1.1  # Zoom out   
		
		if !toggle_zoom_clamp:
			zoom = clamp(zoom, min_zoom, max_zoom)
			
		SignalBus.camera_zoom_change.emit(zoom.x) 
		
		
