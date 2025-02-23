extends Node2D

@export_group("Map generation properties")
@export var mapsize = 100
@export var room_amount = 5
@export var room_size_min = 10  # Minimum room size, increased to make rooms bigger
@export var room_size_max = 20  # Maximum room size, feel free to tweak
@export_group("Tiles to use")
@export var atlas_id = 0
@export var inside_pos = Vector2i(9, 3) # path tile
@export var outside_pos = Vector2i(2, 4) # wall tile
# 8,3 is wall edge non nav path tile, note any path tile should have buffer tile
@export var wall_edge_pos = Vector2i(8, 3) 

var rooms: Array[Rect2] = []
var room_centers: Array[Vector2] = []

# Converted to world coord
var room_centers_converted: Array[Vector2] = []

func _ready() -> void:
	print("proc_gen ready..")
	# Clear out previous rooms
	rooms.clear()
	room_centers.clear()
	
	# Fill the map with outside tiles
	for x in range(mapsize):
		for y in range(mapsize):
			$TileMapLayer.set_cell(Vector2i(x, y), atlas_id, outside_pos, 0)
	
	# Generate rooms
	generate_rooms()

	# Generate corridors between rooms
	connect_rooms_with_corridors()
	
	# fix nav gaps between rooms and corridors
	fix_nav_gap_tiles()
	
	SignalBus.map_generated.emit()

# Generates rooms on the map
func generate_rooms():
	var attempts = 0
	var max_attempts = 100

	# First, generate a fixed room at (15, 15) for the player spawn
	var spawn_room_width = 7
	var spawn_room_height = 7
	var spawn_room = Rect2(Vector2(15, 15), Vector2(spawn_room_width, spawn_room_height))
	rooms.append(spawn_room)
	room_centers.append(spawn_room.position + spawn_room.size / 2)
	room_centers_converted.append($TileMapLayer.map_to_local(spawn_room.position + spawn_room.size / 2) * $TileMapLayer.scale)
	draw_room(spawn_room)

	# Then, generate the other rooms around it
	while rooms.size() < room_amount and attempts < max_attempts:
		var room_width = randi_range(room_size_min, room_size_max)
		var room_height = randi_range(room_size_min, room_size_max)
		
		var room_x = randi_range(1, mapsize - room_width - 1)
		var room_y = randi_range(1, mapsize - room_height - 1)
		
		var new_room = Rect2(room_x, room_y, room_width, room_height)

		if is_room_valid(new_room):
			rooms.append(new_room)
			room_centers.append(new_room.position + new_room.size / 2)
			room_centers_converted.append($TileMapLayer.map_to_local(new_room.position + new_room.size / 2) * $TileMapLayer.scale)
			draw_room(new_room)
		
		attempts += 1

# Checks if a room overlaps with existing rooms
func is_room_valid(new_room: Rect2) -> bool:
	for room in rooms:
		if room.intersects(new_room):
			return false
	return true

# Draws a room on the map
func draw_room(room: Rect2):
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			if x >= 0 and y >= 0 and x < mapsize and y < mapsize:
				$TileMapLayer.set_cell(Vector2i(x, y), atlas_id, inside_pos, 0)
				
				
	# add tile between outside and inside to prevent navigation next to walls
	apply_nonNavTile_between_inside_and_outside(room)
   
func connect_rooms_with_corridors():
	if room_centers.size() < 2:
		return
	for i in range(1, room_centers.size()):
		# Connect corridors using these points
		connect_two_rooms(room_centers[i - 1], room_centers[i])

# Connects two rooms with a corridor
func connect_two_rooms(start: Vector2, end: Vector2):
	var start_x = int(start.x)
	var start_y = int(start.y)
	var end_x = int(end.x)
	var end_y = int(end.y)
	
	var corridor_tiles = []
	
	# Draw horizontal corridor (3 wide)
	if start_x > end_x:
		for x in range(end_x - 1, start_x + 2):
			for y in range(start_y - 1, start_y + 2):  # 3 tiles wide vertically
				$TileMapLayer.set_cell(Vector2i(x, y), atlas_id, inside_pos, 0)
				corridor_tiles.append(Vector2i(x,y))
	else:
		for x in range(start_x - 1, end_x + 2):
			for y in range(start_y - 1, start_y + 2):  # 3 tiles wide vertically
				$TileMapLayer.set_cell(Vector2i(x, y), atlas_id, inside_pos, 0)
				corridor_tiles.append(Vector2i(x,y))
				
	# Draw vertical corridor (3 wide)
	if start_y > end_y:
		for y in range(end_y - 1, start_y + 2):
			for x in range(end_x - 1, end_x + 2):  # 3 tiles wide horizontally
				$TileMapLayer.set_cell(Vector2i(x, y), atlas_id, inside_pos, 0)
				corridor_tiles.append(Vector2i(x,y))
	else:
		for y in range(start_y - 1, end_y + 2):
			for x in range(end_x - 1, end_x + 2):  # 3 tiles wide horizontally
				$TileMapLayer.set_cell(Vector2i(x, y), atlas_id, inside_pos, 0)
				corridor_tiles.append(Vector2i(x,y))
	
	# Ensure the corner where the two corridors meet is filled
	$TileMapLayer.set_cell(Vector2i(end_x, start_y), atlas_id, inside_pos, 0)
	
	# apply non nav tiles to the corridors
	for tile in corridor_tiles:
		if is_adjacent_to_outside(tile):
			$TileMapLayer.set_cell(tile, atlas_id, wall_edge_pos, 0)
			

# apply non nav tiles between path and walls
func apply_nonNavTile_between_inside_and_outside(room: Rect2):
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			var pos = Vector2i(x, y)
			if $TileMapLayer.get_cell_atlas_coords(pos) == inside_pos:
				if is_adjacent_to_outside(pos):
					$TileMapLayer.set_cell(pos, atlas_id, wall_edge_pos, 0)

# check if a tile is adjacent to an outside tile
func is_adjacent_to_outside(pos: Vector2i) -> bool:
	var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for dir in directions:
		var neighbor_pos = pos + dir
		if $TileMapLayer.get_cell_atlas_coords(neighbor_pos) == outside_pos:
			return true
	return false

# fix path gaps between rooms or corridors
func fix_nav_gap_tiles():
	for x in range(mapsize):
		for y in range(mapsize):
			var pos = Vector2i(x, y)
			var tile_type = $TileMapLayer.get_cell_atlas_coords(pos)
			# if its a non nav tile, check if its sandwiched between two inside tiles
			if tile_type == wall_edge_pos:
				if (is_inside_tile(pos + Vector2i(-1, 0)) and is_inside_tile(pos + Vector2i(1, 0))) or \
				   (is_inside_tile(pos + Vector2i(0, -1)) and is_inside_tile(pos + Vector2i(0, 1))):
					# replace it with an inside tile
					$TileMapLayer.set_cell(pos, atlas_id, inside_pos, 0)

# helper function to check if a tile is an inside tile
func is_inside_tile(pos: Vector2i) -> bool:
	return $TileMapLayer.get_cell_atlas_coords(pos) == inside_pos
