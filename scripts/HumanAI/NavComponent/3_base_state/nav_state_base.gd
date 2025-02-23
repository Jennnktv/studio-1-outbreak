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
	# base move, two classes depend on it with same logic
	# wait for navigationServer to be ready
	while NavigationServer2D.map_get_iteration_id(navAgent.get_navigation_map()) == 0:
		await get_tree().physics_frame
		
	var attempts = 2
	while attempts > 0:
		await get_tree().physics_frame
		# if we got a target lets set the nav target position
		# Pick a random room center
		var tile_target = nav_comp_prop.room_centers[randi() % nav_comp_prop.room_centers.size()]  
		
		if tile_target != Vector2.ZERO:
			navAgent.target_position = tile_target
			
			#rotate_sprite_towards_target(tile_target)
			return  
		attempts -= 1

func Update(_delta: float):
	if !character or !navAgent or !nav_comp_prop.player:
		return
	
	# check our distance, might want to add a cooldown to reduce calls
	distance_to_player = character.global_position.distance_to(nav_comp_prop.player.global_position)
	
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
