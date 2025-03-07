extends Node

# A game state node to manage start, end and potential balancing of resources
# TODO: move game start logic here
# NOTE: if logic for tracking current stim # is implemented, 
# 		connect to the signal and implement balancing here on changes

const GAME_END_UI = preload("res://scenes/game_end_UI.tscn")

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var player: CharacterBody2D = $CharacterBody2D

func _ready() -> void:
	SignalBus.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	# disable player movement
	$CanvasLayer/SanityBar.set_process(false)
	player.set_physics_process(false)
	$CanvasLayer/Lighting._update_light_radius(0.0)
	
	# var game_end_ui = GAME_END_UI.instantiate() 
	# canvas_layer.add_child(game_end_ui)
	
	get_tree().change_scene_to_file("res://scenes/game_end_UI.tscn")
