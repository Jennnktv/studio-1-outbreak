class_name SanityConfiguration extends Resource

@export_group("Sanity Configuration")
@export var sanity_deplete_rate: float = 0.05
@export var sanity_pristine_cooldown: float = 1.0 # Seconds

@export_group("Fury Configuration")
@export var fury_cooldown: float = 5 # Seconds

@export_group("Stimulant Settings")
@export var stimulant_recharge_rate: float = 0.2

@export_group("Status Effects")
@export var psychological_cue_points: Array[PsychologicalCuePoint]
@export var gameplay_cue_points: Array[GameplayCuePoints]
