extends Node

@onready var visibleOnScreenEnabler2d := $VisibleOnScreenEnabler2D

# can add some random object positions

func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	get_node("Nodes").show()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	get_node("Nodes").hide()
