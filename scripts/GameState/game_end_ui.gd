extends Control

@onready var retry_button: Button = $AspectRatioContainer/CenterContainer/Panel/VBoxContainer/RetryButton
@onready var highscore_label: Label = $AspectRatioContainer/CenterContainer/Panel/VBoxContainer/HighscoreLabel
@onready var time_survived_label: Label = $AspectRatioContainer/CenterContainer/Panel/VBoxContainer/TimeSurvivedLabel

var ui_updated = false

func _ready() -> void:
	time_survived_label.text = "Time Survived: 00:00"
	highscore_label.text = "Highscore: 0"
	
	retry_button.pressed.connect(_on_retry_pressed)

func show_game_over(time_survived: int, highscore: int) -> void:		
	var minutes = int(time_survived / 60)
	var seconds = time_survived % 60

	time_survived_label.text = "Time Survived: %02d:%02d" % [minutes, seconds]
	highscore_label.text = "Highscore: %02d" % [highscore]
	
func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
