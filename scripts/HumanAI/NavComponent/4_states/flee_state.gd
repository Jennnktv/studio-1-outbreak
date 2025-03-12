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
	super.process_move()

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
