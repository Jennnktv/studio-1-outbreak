extends nav_state_base
class_name wander_state

###########################
# wander state class - for wandering and trans into flee state
# -enter
# -exit
# -process move
# -update
# -physics update
###########################
#E3C

func Enter():
	super.Enter()
	#print("Wandering...")
	navAgent.target_position = character.global_position
	nav_comp_prop.start_cooldown("state_changed", nav_comp_prop.wander_transition_time)
	navAgent.max_speed = nav_comp_prop.wander_speed
	character.get_node("Sprite").self_modulate = Color(0,0,1,1)

func Exit():
	super.Exit()
	#print("Wander Exit!")

func process_move():
	super.process_move()

func Update(_delta: float):
	super.Update(_delta)

func Physics_Update(_delta: float):
	super.Physics_Update(_delta)
	
	# check our distance vs the min flee distance and change state if we meet
	# condition, make sure the distance doesnt start with 0
	if distance_to_player < nav_comp_prop.flee_distance_min and !nav_comp_prop.is_infected and distance_to_player > 0:
		#print("Player is near! Fleeing!")
		Transitioned.emit(self, "flee_state")
		
		# check if we reached target position
	if navAgent.is_target_reached():
		# reset path once we get there and start another process move
		navAgent.target_position = character.global_position
		nav_comp_prop.start_cooldown("target_reached", nav_comp_prop.wander_transition_time)
		process_move()
