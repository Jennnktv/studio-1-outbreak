extends nav_state_base
class_name infected_state

###########################
# infection state class - for infected
# -enter
# -exit
# -process move
# -update
# -physics update
###########################
#E3C

func Enter():
	super.Enter()
	#print("Infected...")
	if !character.is_in_group("light"):
		character.add_to_group("light")
	
	nav_comp_prop.start_cooldown("state_changed", nav_comp_prop.infected_transition_time)
	
	if !nav_comp_prop.cooldowns.has("death_timer"):
		nav_comp_prop.start_cooldown("death_timer", nav_comp_prop.death_timer)
	
	nav_comp_prop.is_infected = true
	navAgent.max_speed = nav_comp_prop.infected_speed
	character.get_node("Sprite").self_modulate = Color(1,0,0,1)
	Score.bump_infected()
	
	process_move()

func Exit():
	super.Exit()
	#print("Infected Exit!")

func process_move():
	super.process_move()

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
		#print("Infected.. Target Reached")
		nav_comp_prop.start_cooldown("target_reached", nav_comp_prop.infected_transition_time)
		#Transitioned.emit(self, "search_state")
		process_move()

func Physics_Update(_delta: float):
	super.Physics_Update(_delta)
