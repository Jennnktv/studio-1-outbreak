class_name HumanStatePanic extends HumanStateBase

func enter():
	navigator.navigation_finished.connect(_on_navigation_finished)
	_on_navigation_finished()
	sprite.modulate = Color(1, 0, 0)
	pass

func exit():
	navigator.navigation_finished.disconnect(_on_navigation_finished)
	sprite.modulate = Color(1, 1, 1)
	pass

func update(_delta: float):
	sprite.play("walk", HumanConfigurationResource.GOLDEN_RATIO * 2)

func physics_update(_delta: float):
	navigate(configuration.running_speed)
	if is_player_on_sight():
		update_navigator_target_position()
	

func _on_navigation_finished():
	if is_safe_place(body.global_position):
		transition_to_normal()
	else:
		update_navigator_target_position()

func update_navigator_target_position():
	navigator.target_position = pick_safe_place()

func pick_safe_place():
	# add logic to find a safe place, for now returns a random position
	return Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))

func is_safe_place(_position: Vector2) -> bool:
	# add logic to check if a position is safe
	return randi() % 20 == 0
