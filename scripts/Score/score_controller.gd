class_name ScoreController extends Node

#region enums / singleton / signals / constants

const SCORE_FIELD = "score"
const TIMESTAMP_FIELD = "timestamp"

enum ScoreType { 
	STIMULANTS, 
	INFECTED_HUMANS
}

signal score_changed(score_type: ScoreType, score: int)
signal score_changing(score_type: ScoreType, score: int)

#endregion

#region exports

@export var total_score_types: Array[ScoreType] = [
	ScoreType.STIMULANTS,
	ScoreType.INFECTED_HUMANS
]

#endregion

#region members

var values: Dictionary = {
	ScoreType.STIMULANTS: 0,
	ScoreType.INFECTED_HUMANS: 0
}

var ledger: Dictionary = {
	ScoreType.STIMULANTS: [],
	ScoreType.INFECTED_HUMANS: []
}

#endregion

func push(score_type: ScoreType, score: int) -> void:
	score_changing.emit(score_type, score)
	_append_score(score_type, score, Time.get_unix_time_from_system())
	score_changed.emit(score_type, score)

func get_score(score_type: ScoreType) -> int:
	return values[score_type]

func get_total_score() -> int:
	return total_score_types.reduce(func(acc, score_type): return acc + values[score_type], 0)

func _append_score(score_type: ScoreType, score: int, timestamp: float) -> void:
	var entry = { SCORE_FIELD: score, TIMESTAMP_FIELD: timestamp}
	ledger[score_type].append(entry)
	values[score_type] += score

func bump_stimulants():
	push(ScoreType.STIMULANTS, 1)

func bump_infected():
	push(ScoreType.INFECTED_HUMANS, 1)
