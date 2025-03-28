class_name HumanStateInfected extends HumanStateBase

var is_chasing_stim: bool = false
var visited_places: Array = []

func enter():
	navigator.navigation_finished.connect(_on_navigation_finished)
	sprite.modulate = Color(1, 1, 0)
	_on_navigation_finished()
	pass

func exit():
	navigator.navigation_finished.disconnect(_on_navigation_finished)
	sprite.modulate = Color(1, 1, 1)
	pass

func update(_delta: float):
	sprite.play("walk", HumanConfigurationResource.GOLDEN_RATIO/2)
	if is_chasing_stim:
		sensors.rotation = 0
		sprite.modulate = Color(0, 0, 1)
	else:
		sensors.rotation = lerp_angle(sensors.rotation, sin(Time.get_ticks_msec()/200) * deg_to_rad(45), 0.1)

func physics_update(_delta: float):
	navigate(configuration.walking_speed / 2 if is_chasing_stim else configuration.walking_speed)
	if is_stims_on_sight() and not is_chasing_stim:
		is_chasing_stim = true
		var first_stim = get_stims_on_sight()[0]
		navigator.target_position = first_stim.position
		visited_places.clear()

func _on_navigation_finished():
	update_navigator_target_position()

func update_navigator_target_position():
	visited_places.append(navigator.target_position)
	if visited_places.size() > 10:
		visited_places.pop_front()
	navigator.target_position = pick_random_place()

func pick_random_place(count = 0):
	# Randomly pick a place to navigate to
	# If the place is already visited, pick another one
	# If the count exceeds 10, return a default position
	# This is to prevent infinite loops
	if count > 10:
		return Vector2.ZERO
	var next_place = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
	if is_already_visited(next_place):
		return pick_random_place(count + 1)
	return next_place

func is_already_visited(position: Vector2) -> bool:
	for place in visited_places:
		if position.distance_to(place) < configuration.stim_radius:
			return true
	return false