extends Node
class_name nav_state_base

###########################
# base class for all states
# -base class vars
# -enter
# -exit
# -process move
# -update
# -physics update
# -helper func 
###########################
#E3C

@warning_ignore("unused_signal") signal Transitioned

# base properties from nav_comp
@onready var nav_comp_prop: nav_component_properties = null
@onready var character: CharacterBody2D = null
@onready var navAgent: NavigationAgent2D = null
@onready var sprite: AnimatedSprite2D = null

# base distance check
var distance_to_player: float = 0:
	set(value):
		_distance_to_player = value
	get():
		return _distance_to_player
var _distance_to_player: float = 0

func Enter():
	# check if we want debug
	if nav_comp_prop.is_debug:
		navAgent.debug_enabled = nav_comp_prop.is_debug
	else:
		navAgent.debug_enabled = nav_comp_prop.is_debug
	
	# wait for next frame
	await get_tree().physics_frame
	# reset path everytime we enter this state
	navAgent.target_position = character.global_position

func Exit():
	# nothing for base atm
	pass

func process_move():
	
	# Wait for NavigationServer to be ready
	while NavigationServer2D.map_get_iteration_id(navAgent.get_navigation_map()) == 0:
		await get_tree().physics_frame

	# Ensure there are valid room centers
	if nav_comp_prop.room_centers.is_empty():
		return

	# Find the closest room center that is NOT the current position
	var ai_position = character.global_position
	var closest_room = null
	var min_distance = INF  # Set initial distance to a large value

	for room in nav_comp_prop.room_centers:
		var dist = ai_position.distance_to(room)
		if dist < min_distance and dist > 100.0:  # Avoid selecting current location
			min_distance = dist
			closest_room = room
	
	# If a valid target was found, move there
	if closest_room:
		navAgent.target_position = closest_room
		print("Moving to:", closest_room)



func Update(_delta: float):
	if !character or !navAgent or !nav_comp_prop.player:
		return
	
	# check our distance, might want to add a cooldown to reduce calls
	distance_to_player = character.global_position.distance_to(nav_comp_prop.player.global_position)
	
	if distance_to_player > 1000 and !nav_comp_prop.is_infected:
		return
	
	#cycle our cooldowns and remove if 0, can make a pool to decrease object creation
	nav_comp_prop.cycle_timer_cooldowns(_delta)
	 
	# check our cooldowns
	if nav_comp_prop.is_on_cooldown("state_changed") or nav_comp_prop.is_on_cooldown("target_reached"):
		sprite.play("idle")
		return
		
	if character.velocity != Vector2.ZERO:
		sprite.speed_scale = 1
		sprite.play("walk")
	else: 
		sprite.speed_scale = 1
		sprite.play("idle")

func Physics_Update(_delta: float):
	if !character or !navAgent or !nav_comp_prop.player:
		# something is null
		return
		
	if distance_to_player > 1000 and !nav_comp_prop.is_infected:
		return
	
	# check cooldowns so we dont get jitter
	if nav_comp_prop.is_on_cooldown("state_changed") or nav_comp_prop.is_on_cooldown("target_reached"):
		# if on cooldown lets return because we dont want it to move
		#print("On CoolDown")
		return
	
	rotate_sprite_towards_target(navAgent.get_next_path_position())
	
	# safe to move to the nav path, speed is set in state classes
	character.velocity = character.global_position.direction_to(navAgent.get_next_path_position()).normalized() * navAgent.max_speed
	character.move_and_slide()

# HELPER FUNCs
func rotate_sprite_towards_target(target_position: Vector2):
	sprite.rotation = (target_position - character.global_position).normalized().angle()
