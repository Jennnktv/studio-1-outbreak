extends nav_state_base
class_name flee_state

###########################
# flee state class - for fleeing and trans into infected or wandering
# -enter
# -exit
# -process move (override)
# -update
# -physics update

# Note: Could try and make this smarter..
# sometimes it runs back into the player
###########################
#E3C

var trapped
var valid_paths = []
var last_path

var max_attempts = 8

func Enter():
	super.Enter()
	#print("Flee...")
	navAgent.max_speed = nav_comp_prop.flee_speed
	character.get_node("Sprite").self_modulate = Color(0,1,0,1) # debug

func Exit():
	super.Exit()
	#print("Flee Exit!")
	# zero out our last flee target on exit
	last_path = Vector2.ZERO
	valid_paths.clear()
	trapped = false

func process_move():
	# ensure navigationServer is ready
	while NavigationServer2D.map_get_iteration_id(navAgent.get_navigation_map()) == 0:
		await get_tree().physics_frame
	
	valid_paths.clear()
	
	# check all room centers
	for room_center in nav_comp_prop.room_centers:
		if last_path == room_center:
			continue
			
		# skip if the player is on the path
		if is_player_on_path(NavigationServer2D.map_get_path(navAgent.get_navigation_map(), character.global_position, room_center, 0), nav_comp_prop.player.global_position):
			continue
		
		# add the valid path to choices
		valid_paths.append(room_center)
		
	# pick a random valid path
	if valid_paths.size() > 0:
		navAgent.target_position = valid_paths[randi() % valid_paths.size()]
		last_path = navAgent.target_position
		trapped = false
		return
		
	# try move around player if trapped
	for i in range(max_attempts):
		var escape_target = nav_comp_prop.player.global_position + Vector2(cos(deg_to_rad(i * nav_comp_prop.escape_angle_step)), sin(deg_to_rad(i * nav_comp_prop.escape_angle_step))) * nav_comp_prop.escape_radius
		# check if we can navigate there
		var escape_path = NavigationServer2D.map_get_path(navAgent.get_navigation_map(), character.global_position, escape_target, 0)
		if !is_player_on_path(escape_path, nav_comp_prop.player.global_position):
			navAgent.target_position = escape_target
			#print("Moving around the player to escape:", escape_target)
			trapped = false
			return

	# if we can't find an escape,
	#print("Still stuck! Trapped like a RAT! This is the END!")
	trapped = true

func Update(_delta: float):
	super.Update(_delta)
	
	# check if we reached target position
	if navAgent.is_target_reached():
		# reset path once we get there and start another process move
		#print("Flee Path Reached")
		process_move()
		
	# play flee animation
	if !trapped:
		sprite.speed_scale = 2
		sprite.play("walk")
	else:
		sprite.speed_scale = 1
		sprite.play("idle")

func Physics_Update(_delta: float):
	super.Physics_Update(_delta)
	
	# check to see if we are close enough to get infected
	if distance_to_player < nav_comp_prop.infection_distance and !nav_comp_prop.is_infected and distance_to_player > 0:
		#print("Player is close! Infected! ", nav_comp_prop.infection_distance, " distance: ", distance_to_player)
		nav_comp_prop.is_infected = true
		Transitioned.emit(self, "infected_state")
		
	# check if we are to far, go wandering again
	if distance_to_player > nav_comp_prop.flee_distance_max and !nav_comp_prop.is_infected and distance_to_player > 0:
		#print("Safe distance reached, switching to wander state...")
		Transitioned.emit(self, "wander_state")

func is_player_on_path(path: Array, player_pos: Vector2) -> bool:
	for point in path:
		if point.distance_to(player_pos) < nav_comp_prop.safe_distance:
			#print("Skipping path, player is too close!")
			return true
	return false
