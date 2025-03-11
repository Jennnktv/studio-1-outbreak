class_name WireScoreController extends Node

@export var left_pad: int = 3
@export var left_pad_char: String = "0"
@export var label: Label
@export var use_high_score: bool = false
@export var score_type: Score.ScoreType
@export var show_total_score: bool = false
@export var wait_for_score_loading: bool = false

var template = ""

func _ready():
	if label == null:
		label = get_parent()
	if label == null:
		push_error("WireScoreController requires a Label node to display the score.")
		return
	template = label.text

func _process(_delta):
	if label != null and (not wait_for_score_loading or Score.is_loaded()):
		var value = 0
		
		if use_high_score and show_total_score:
			value = Score.get_total_high_score()
		elif use_high_score and not show_total_score:
			value = Score.get_high_score(score_type)
		elif not use_high_score and show_total_score:
			value = Score.get_total_score()
		else: 
			value = Score.get_score(score_type)
		
		label.text = template % str(value).lpad(left_pad, "0")
