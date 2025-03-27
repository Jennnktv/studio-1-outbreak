class_name StateMachine extends Node

@export var initial_state: StateNode

var states = {}
var current_state = null

signal state_changed(new_state_name: String, old_state_name: String)
signal state_entered(new_state_name: String)
signal state_exited(old_state_name: String)

func _ready():
	for child in get_children():
		if child is StateNode:
			states[child.name] = child
			child.state_machine = self
	if initial_state:
		change_state(initial_state.name)

func change_state(new_state_name: String):
	var old_state_name = current_state.name if current_state else null 
	if current_state:
		state_exited.emit(current_state.name)
		current_state.exit()
	
	current_state = states.get(new_state_name, null)
	if current_state:
		current_state.enter()
		state_entered.emit(current_state.name)
		state_changed.emit(new_state_name, old_state_name)

func update(delta: float):
	if current_state:
		current_state.update(delta)

func physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float):
	update(delta)

func _physics_process(delta: float):
	physics_update(delta)
