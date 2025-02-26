class_name HUD extends Control

@export var cooldown_time: float = 1.0
@export var injection_label: Label
@export var infected_label: Label
@export var injection_icon: TextureRect
@export var infected_icon: TextureRect

@export var highlight_colors: Dictionary = {
	Score.ScoreType.STIMULANTS: Color.GREEN,
	Score.ScoreType.INFECTED_HUMANS: Color.VIOLET
}

var cooldown = {}

func _ready() -> void:
	Score.score_changed.connect(on_score_changed)

func _process(_delta: float) -> void:
	for score_type in Score.total_score_types:
		if score_type in cooldown:
			cooldown[score_type] -= _delta
			if cooldown[score_type] <= 0:
				cooldown.erase(score_type)
			if score_type == Score.ScoreType.STIMULANTS:
				animate_icon(injection_icon, score_type)
			elif score_type == Score.ScoreType.INFECTED_HUMANS:
				animate_icon(infected_icon, score_type)

	reset_icon(injection_icon)
	reset_icon(infected_icon)

func on_score_changed(score_type: Score.ScoreType, _score: int) -> void:
	cooldown[score_type] = cooldown_time

func animate_icon(icon: TextureRect, score_type: Score.ScoreType) -> void:
	icon.modulate = highlight_colors[score_type]
	icon.position = Vector2(0, -5)

func reset_icon(icon: TextureRect) -> void:
	icon.modulate = lerp(icon.modulate, Color(1, 1, 1, 1), 0.1)
	icon.position = lerp(icon.position, Vector2(0, 0), 0.1)
