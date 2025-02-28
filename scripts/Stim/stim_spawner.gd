class_name StimSpanwer extends Node

const STIM = preload("res://scenes/stim.tscn")
const HUMAN = preload("res://scenes/human.tscn")
const CUSTOM_DATA_KEY = "stim_spawnable"

@export var stim_container:Node2D
@export var tile_map_layer:TileMapLayer
@export var stim_count:int = 0

func _ready() -> void:
	await SignalBus.map_generated
	if tile_map_layer:
		spawn_stims()


func spawn_stims() -> void:
	if tile_map_layer:
		var markers: Array = []
				
		for marker: Node2D in tile_map_layer.get_children():
			markers.append(marker.global_position)

		print("markers: ", markers.size())

		for i in range(stim_count, 0, -1,):
			if markers.size() == 0:
				break
			markers.shuffle()
			var cell_coords = markers.pop_front() as Vector2
			var _stim = STIM.instantiate()
			_stim.global_position = cell_coords
			stim_container.add_child(_stim)
			# var _human = HUMAN.instantiate()
			# _human.global_position = _stim.global_position
			# stim_container.call_deferred("add_child", _human)
			#print("stim added")
				
