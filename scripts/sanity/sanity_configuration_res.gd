class_name SanityConfiguration extends Resource

@export_group("Deplete Rates")
@export var sanity_deplete_rate: float = 0.05
@export var fury_deplete_time: float = 5

@export_group("Stimulant Settings")
@export var stimulant_recharge_rate: float = 0.2

@export_group("Status Effects")
@export var psychological_cue_points: Array[PsychologicalCuePoint]
@export var gameplay_cue_points: Array[GameplayCuePoints]
