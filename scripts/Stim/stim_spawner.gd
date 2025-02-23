class_name StimSpanwer extends Node

const STIM = preload("res://scenes/stim.tscn")
const HUMAN = preload("res://scenes/human.tscn")

@export var stim_container:Node2D
@export var tile_map_layer:TileMapLayer
@export var stim_count:int = 0
@export var tile_ids:Array[int] = []

func _ready() -> void:
	await SignalBus.map_generated
	if tile_map_layer:
		spawn_stims()


func spawn_stims() -> void:
	if tile_map_layer:
		var placeable_tiles = []
				
		for cell_coords:Vector2i in tile_map_layer.get_used_cells():
			var cell_data = tile_map_layer.get_cell_tile_data(cell_coords)
			if bool(cell_data.get_custom_data("stim_spawnable")):
				placeable_tiles.append(cell_coords)
				
		if placeable_tiles.size() > stim_count:
			for i in range(stim_count, 0, -1,):
				var cell_coords = Rng.array_pick_random(placeable_tiles)
				var _stim = STIM.instantiate()
				_stim.global_position = tile_map_layer.to_global(tile_map_layer.map_to_local(cell_coords))
				stim_container.call_deferred("add_child", _stim)
				var _human = HUMAN.instantiate()
				_human.global_position = _stim.global_position
				stim_container.call_deferred("add_child", _human)
				#print("stim added")
				
