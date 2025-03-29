class_name HumanStateNormal extends HumanStateBase

@export var spots: Array[Marker2D] = []

var current_spot_index: int = 0
	
func enter():
	navigator.navigation_finished.connect(_on_navigation_finished)
	_on_navigation_finished()
	pass

func exit():
	navigator.navigation_finished.disconnect(_on_navigation_finished)
	pass

func update(_delta: float):
	sprite.play("walk", HumanConfigurationResource.GOLDEN_RATIO)

func physics_update(_delta: float):
	navigate(configuration.walking_speed)
	if is_player_on_sight() or is_human_panic_on_sight():
		transition_to_panic()

func _on_navigation_finished():
	navigator.target_position = pick_new_target()

func pick_new_target():
	if not spots:
		return body.global_position * (randf() * 100)
	current_spot_index += 1
	if current_spot_index >= spots.size():
		current_spot_index = 0
	return spots[current_spot_index].global_position
