class_name SanityController extends Node

static var instance: SanityController

@onready var sanity_value: ActiveValue = $SanityValue

@export var configuration: SanityConfiguration

func _ready():
	if instance:
		print_debug("SanityController: multiple instances detected. This is not allowed.")
	else:
		instance = self

func _process(delta: float) -> void:
	if not configuration:
		return

	if sanity_value.current_value > 0:
		sanity_value.set_value(sanity_value.current_value - configuration.sanity_deplete_rate * delta)
