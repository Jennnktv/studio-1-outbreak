extends Node

var instance: RandomNumberGenerator


func _ready() -> void:
	initialize()


func initialize() -> void:
	instance = RandomNumberGenerator.new()
	instance.randomize()

 
func set_from_save_data(which_seed: int, state: int) -> void:
	instance = RandomNumberGenerator.new()
	instance.seed = which_seed
	instance.state = state

func pick_random_number(limit: int) -> int:
	return instance.randi() % limit
	
func randf_range(low: float, high:float) -> float:
	return instance.randf_range(low, high)


func array_pick_random(array: Array) -> Variant:
	if array.size() > 0:
		return array[instance.randi() % array.size()]
	return null


func dictionary_pick_random(dictionary: Dictionary) -> Variant:
	if dictionary.size() > 0:
		return dictionary[instance.randi() % dictionary.size()]
	return null


func array_shuffle(array: Array) -> void:
	if array.size() < 2:
		return

	for i:int in range(array.size()-1, 0, -1):
		var j:int = instance.randi() % (i + 1)
		var tmp:Variant = array[j]
		array[j] = array[i]
		array[i] = tmp
