class_name WireScoreController extends Node

@export var template: String = "Stims: %s"
@export var left_pad: int = 3
@export var left_pad_char: String = "0"
@export var label: Label
@export var score_type: Score.ScoreType
@export var show_total_score: bool = false

func _ready():
	if label == null:
		label = get_parent()
	if label == null:
		push_error("WireScoreController requires a Label node to display the score.")
		return

func _process(_delta):
	if label != null:
		label.text = template % str(Score.get_total_score() if show_total_score else Score.get_score(score_type)).lpad(left_pad, "0")
