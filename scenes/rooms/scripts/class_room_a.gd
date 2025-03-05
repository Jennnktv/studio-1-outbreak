extends base_room
class_name class_room_a

@onready var visibleOnScreenEnabler2d := $VisibleOnScreenEnabler2D
@export var room_width: int
@export var room_height: int

# can add some random object positions

func _ready() -> void:
	#print("Class_Room_A ready and add to SignalBus.Map_Generated")
	super._ready()
	width = room_width
	height = room_height
	
	call_deferred("gen_corridors")



func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	get_node("Nodes").show()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	get_node("Nodes").hide()
