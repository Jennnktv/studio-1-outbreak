extends Area2D

func _on_body_entered(_body):
	SignalBus.stim_collected.emit()
	queue_free()
		
