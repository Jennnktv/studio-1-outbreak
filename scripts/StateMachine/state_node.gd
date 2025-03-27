class_name StateNode extends Node

var state_machine: StateMachine

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass

func transition_to(state_name: String):
	state_machine.change_state(state_name)