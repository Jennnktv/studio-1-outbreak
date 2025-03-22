extends Node

# A game state node to manage start, end and potential balancing of resources
# TODO: move game start logic here
# NOTE: if logic for tracking current stim # is implemented, 
# 		connect to the signal and implement balancing here on changes

const GAME_END_UI = preload("res://scenes/game_end_UI.tscn")

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var player: CharacterBody2D = $CharacterBody2D

var start_time: int = 0

func _ready() -> void:
	start_time = Time.get_unix_time_from_system()
	SignalBus.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	# disable player movement
	$CanvasLayer/SanityBar.set_process(false)
	player.set_physics_process(false)
	$CanvasLayer/Lighting._update_light_radius(0.0)
	
	var high_score = Score.get_total_high_score()
	var time_survived = Time.get_unix_time_from_system() - start_time
	
	SignalBus.game_over_score_reset.emit()
	
	var game_over_ui = GAME_END_UI.instantiate()
	canvas_layer.add_child(game_over_ui)
	game_over_ui.show_game_over(time_survived, high_score)
