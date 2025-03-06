extends Control

@onready var score: Label = %Score

func _ready() -> void:
	_set_score()

func _set_score() -> void:
	score.text = str(Score.get_total_score())

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
