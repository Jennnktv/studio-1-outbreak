extends Node

###########################
# state machine class - controls switching between different states
# -ready
# -process
# -physics process
# -transition signal (on_child_transition)
###########################
# E3C

# give the user the option to set the initial state
@export var initial_state : nav_state_base

# current state
var current_state : nav_state_base
# holds our state types
var states: Dictionary = {}

func _ready():
	#await SignalBus.map_generated
	
	#print("nav_state_machine ready")
	 # load our Character
	var character = self.get_parent().get_parent() as CharacterBody2D
	if character == null:
		print("Couldnt find Character as CharacterBody2D! ")
		return
	
	# load the navAgent
	var navAgent = self.get_parent().get_node_or_null("NavigationAgent2D") as NavigationAgent2D
	if navAgent == null:
		print("Couldnt find NavAgent as NavigationAgent2D!")
		return
	
	# load our NavComponent that has the prop script
	var nav_comp_prop = self.get_parent() as Node2D
	if nav_comp_prop == null:
		print("Couldnt find NavComponent!")
		return
	
	nav_comp_prop.player = character.get_parent().get_parent().get_node_or_null("CharacterBody2D")
	#print("PLAYER PATH", character.get_parent().get_parent())
	if nav_comp_prop.player == null:
		print("Couldnt find Player!")
		return
	
	nav_comp_prop.room_centers = character.get_parent().get_parent().room_centers_converted
	#print("Room Centers ", nav_comp_prop.room_centers)
	if nav_comp_prop.room_centers == null:
		print("Couldnt find Room Centers!")
		return
	
	nav_comp_prop.tile_map = character.get_parent().get_parent().get_node("TileMapLayer") as TileMapLayer
	#print("TileMap: ", nav_comp_prop.tile_map)
	if nav_comp_prop.tile_map == null:
		print("Couldnt find TileMap!")
		return
	
	# load the stim targets, this one is not used atm
	#var targetList = self.get_parent().returnList() as Node
	#if targetList == null:
	#	print("Couldnt find TargetList!")
	#	return
	#print(targetList)
	
	# populate our base class
	for child in get_children():
		if child is nav_state_base:
			child.character = character
			child.navAgent = navAgent
			child.sprite = character.get_node_or_null("Sprite")
			#child.targetList = targetList
			child.nav_comp_prop = nav_comp_prop
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float):
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(_navState, new_state_name):
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		# no state found
		return 
	if new_state == current_state:
		# already in state
		return
	if current_state:
		current_state.Exit()
	#if current_state == new_state:
		#print("Re-entering state: " + new_state_name)   
	#else:
		#print("Transitioning to new state: " + new_state_name)
	current_state = new_state
	current_state.Enter()
	#print("Entered new State " + new_state_name)
