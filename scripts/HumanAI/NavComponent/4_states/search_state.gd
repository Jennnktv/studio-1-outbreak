extends nav_state_base
class_name search_state

###########################
# search state class - for infected search rooms, right now more of cone search
# -enter
# -exit
# -process move
# -update
# -physics update
###########################
#E3C

var current_room_center = Vector2.ZERO
var search_spots = []
var is_searching = false

func Enter():
	super.Enter()
	#print("Searching...") 
	if !character.is_in_group("light"):
		character.add_to_group("light")
		
	nav_comp_prop.start_cooldown("state_changed", nav_comp_prop.search_transition_time)
	navAgent.max_speed = nav_comp_prop.infected_speed
	
	process_move()

func Exit():
	super.Exit()
	#print("Search Exit!")

func process_move():
	# ensure navigationServer is ready
	while NavigationServer2D.map_get_iteration_id(navAgent.get_navigation_map()) == 0:
		await get_tree().physics_frame
	
	# find the current room center
	# Find the closest room center that is NOT the current position
	var ai_position = character.global_position
	var closest_room = null
	var min_distance = INF  # Set initial distance to a large value
	var width = null
	var height = null

	for room in nav_comp_prop.room_centers:
		var dist = ai_position.distance_to(room)
		if dist < min_distance and dist > 100.0:  # Avoid selecting current location
			min_distance = dist
			closest_room = room
			width = 60
			height = 30
	
	
	# generate search spots within the room
	search_spots = generate_search_spots(closest_room, Vector2(width * 16, height * 16))  # Radius = 100, 3 spots
	
	# move to the first search spot
	if search_spots.size() > 0:
		navAgent.target_position = search_spots.pop_front()
		is_searching = true
	else:
		navAgent.target_position = closest_room
		is_searching = false

func Update(_delta: float):
	super.Update(_delta)
	# die after the death_timer cooldown
	if !nav_comp_prop.is_on_cooldown("death_timer"):
		#print("DEATH!")
		if character.is_in_group("light"):
			character.remove_from_group("light")
		character.queue_free()
		
	# check if we reached target position
	if navAgent.is_target_reached():
		nav_comp_prop.start_cooldown("target_reached", nav_comp_prop.search_transition_time)
		if is_searching:
			#await get_tree().create_timer(1.5).timeout 
			if search_spots.size() > 0:
				navAgent.target_position = search_spots.pop_front()
			else:
				# no more search spots, return to room center
				#print("Returning to room center...")
				navAgent.target_position = current_room_center
				is_searching = false
		else:
			# done searching, transition to infected state
			#print("Search complete. Transitioning to infected state.")
			Transitioned.emit(self, "infected_state")

func Physics_Update(_delta: float):
	super.Physics_Update(_delta)

func find_nearest_room_center(position: Vector2, possible_paths: Array) -> Vector2:
	var nearest_room_center = Vector2.ZERO
	var min_distance = INF
	for room_center in possible_paths:
		var distance = position.distance_to(room_center)
		if distance < min_distance:
			min_distance = distance
			nearest_room_center = room_center
	return nearest_room_center

func generate_search_spots(center: Vector2, room_size: Vector2) -> Array:
	var spots = []
	# calculate the four corners of the room based on the center and room size
	# if we need a smarter search, will need to get the real room sizes
	var half_width = room_size.x / 2
	var half_height = room_size.y / 2
	
	spots.append(Vector2(center.x - half_width, center.y - half_height))  # Top-left
	spots.append(Vector2(center.x + half_width, center.y - half_height))  # Top-right
	spots.append(Vector2(center.x - half_width, center.y + half_height))  # Bottom-left
	spots.append(Vector2(center.x + half_width, center.y + half_height))  # Bottom-right
	
	return spots
