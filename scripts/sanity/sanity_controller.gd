class_name SanityController extends Node

static var instance: SanityController

@onready var sanity_value: ActiveValue = $SanityValue
@export var configuration: SanityConfiguration

var fury_cooldown: float = 0.0
var pristine_cooldown: float = 0.0

signal fury_cooldown_updated(progress: float)
signal pristine_cooldown_updated(progress: float)
signal sanity_depleting

func _ready():
	if instance:
		print_debug("SanityController: multiple instances detected. This is not allowed.")
	else:
		instance = self

	pristine_cooldown = configuration.sanity_pristine_cooldown

func _process(delta: float) -> void:
	if not configuration:
		return
	
	# if player is on fury, do not deplete sanity
	if fury_cooldown > 0:
		fury_cooldown -= delta
		fury_cooldown_updated.emit(fury_cooldown / configuration.fury_cooldown)
		return
	
	# if player is on pristine, do not deplete sanity
	if pristine_cooldown > 0:
		pristine_cooldown -= delta
		pristine_cooldown_updated.emit(pristine_cooldown / configuration.sanity_pristine_cooldown)
		return

	# deplete sanity
	if sanity_value.current_value > 0:
		sanity_value.decrement(configuration.sanity_deplete_rate * delta)
		sanity_depleting.emit()

func current_psychological_effect() -> Array[PsychologicalCuePoint.PsychologicalHorrorElements]:
	var result: Array[PsychologicalCuePoint.PsychologicalHorrorElements] = []
	for point in configuration.psychological_cue_points:
		if sanity_value.current_value < point.threshold:
			result.append(point.element)
	return result

func current_gameplay_impact() -> Array[GameplayCuePoints.GameplayImpact]:
	var result: Array[GameplayCuePoints.GameplayImpact] = []
	for point in configuration.gameplay_cue_points:
		if sanity_value.current_value < point.threshold:
			result.append(point.element)
	return result

func apply_fury() -> void:
	fury_cooldown = configuration.fury_cooldown
	fury_cooldown_updated.emit(1.0)

func apply_stimulant() -> void:
	sanity_value.increment(configuration.stimulant_recharge_rate)
	if sanity_value.current_value > 0.9:
		reset_pristine_cooldown()

func reset_pristine_cooldown() -> void:
	pristine_cooldown = configuration.sanity_pristine_cooldown
	pristine_cooldown_updated.emit(1.0)
