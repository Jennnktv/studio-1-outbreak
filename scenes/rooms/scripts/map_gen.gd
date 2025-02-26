extends Node2D

@onready var rooms_container := $"../Room_Container"

const ROOM_TYPES := {
	"main_hall": {"scene": preload("res://scenes/rooms/main_hall_a.tscn"), "size": Vector2(60, 30)},
	"class_room": {"scene": preload("res://scenes/rooms/class_room_a.tscn"), "size": Vector2(60, 30)},
	"gym": {"scene": preload("res://scenes/rooms/gym_a.tscn"), "size": Vector2(60, 61)},
	"cafeteria": {"scene": preload("res://scenes/rooms/cafeteria_a.tscn"), "size": Vector2(60, 30)}
}

@export var class_room_num := 8
var rooms := []
@export var tile_size := 16
@export var scale_factor := 4
var spacing := tile_size * scale_factor
var previous_direction := Vector2.RIGHT  # store previous direction
var corridor_tile := Vector2i(9, 3)  # floor
const CORRIDOR_WIDTH := 6  # 6 tiles wide
var corner_width = 6
var corner_height = 6

func _ready():
	generate_aligned_rooms()
	call_deferred("add_corridors")

func generate_aligned_rooms():
	var current_pos := Vector2(10 * spacing, 10 * spacing) # starting position
	
	# place main hall
	var main_hall_data := ROOM_TYPES["main_hall"]
	var main_hall_size = main_hall_data["size"] * spacing
	
	var main_hall_rect := Rect2(current_pos, main_hall_size)
	rooms.append(main_hall_rect)
	spawn_room_instance(main_hall_rect, main_hall_data["scene"], main_hall_data)
	
	var gym_data := ROOM_TYPES["gym"]
	var gym_size = gym_data["size"] * spacing
	var gym_rect = main_hall_rect
	var gym_pos = find_valid_position(gym_rect, gym_size, gym_data)
	gym_rect = Rect2(gym_pos, gym_size)
	
	if gym_pos != Vector2.INF: # If a valid
		rooms.append(gym_rect)
		spawn_room_instance(gym_rect, gym_data["scene"], gym_data)
		gym_rect.position = gym_pos
		#print("Gym placed at:", gym_pos)
	else:
		print("Failed to place Gym")
	
	var cafe_data := ROOM_TYPES["cafeteria"]
	var cafe_size = cafe_data["size"] * spacing
	var cafe_rect := main_hall_rect
	var cafe_pos = find_valid_position(cafe_rect, cafe_size, cafe_data)
	cafe_rect = Rect2(cafe_pos, cafe_size)
	
	if cafe_pos != Vector2.INF:
		rooms.append(cafe_rect)
		spawn_room_instance(cafe_rect, cafe_data["scene"], cafe_data)
		cafe_rect.position = cafe_pos
		#print("cafe placed at:", cafe_pos)
	else:
		print("Failed to place cafe")
	
	var possible_room_positions = [main_hall_rect, cafe_rect]
	for i in range(class_room_num):
		var class_room_data = ROOM_TYPES["class_room"]
		var class_room_size = class_room_data["size"] * spacing
		var random_room = possible_room_positions[randi() % possible_room_positions.size()]
		var class_room_pos = find_valid_position(random_room, class_room_size, class_room_data)
		
		if class_room_pos != Vector2.INF:
			var class_room_rect = Rect2(class_room_pos, class_room_size)
			rooms.append(class_room_rect)
			spawn_room_instance(class_room_rect, class_room_data["scene"], class_room_data)
			possible_room_positions.clear()
			possible_room_positions.append(class_room_rect)
			#print("class room placed at:", class_room_pos)
		else:
			print("Failed to place class room")

func find_valid_position(base_room: Rect2, room_size: Vector2, base_room_data: Dictionary) -> Vector2:
	var directions = [
		Vector2.RIGHT, 
		Vector2.LEFT, 
		Vector2.UP, 
		Vector2.DOWN
	]
	
	directions.shuffle()  # randomize
	
	for dir in directions:
		var new_pos = base_room.position + (dir * (base_room.size + Vector2(spacing, spacing)))
		var new_room = Rect2(new_pos, room_size)
		
		if is_room_valid(new_room):
			return new_pos
	
	return Vector2.INF

func is_room_valid(room: Rect2) -> bool:
	for existing_room in rooms:
		if existing_room.intersects(room, true):
			return false  
	return true

func spawn_room_instance(room: Rect2, scene: PackedScene, room_type: Dictionary):
	var room_instance = scene.instantiate()
	room_instance.global_position = room.position
	#room_instance.rotation = rotation  # rotation
	rooms_container.call_deferred("add_child", room_instance)

func find_room_by_position(target_position: Vector2) -> Rect2:
	for room in rooms:
		if room.position == target_position:
			return room  # Return the found Rect2
	print("No room found at:", target_position)
	return Rect2(0,0,0,0)

func add_corridors():
	#print(rooms_container)
	for room in rooms_container.get_children():
		#print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
		#print("ROOM: ", room.name)
		var tilemap := room.get_node("Nodes").get_node("floor") as TileMapLayer
		
		var room_rect = find_room_by_position(room.position)
		#print(room_rect)
		
		var directions = {
			"left": Vector2(-1, 0),
			"right": Vector2(1, 0),
			"top": Vector2(0, -1),
			"bottom": Vector2(0, 1),
			"top_left": Vector2(-1,-1),
			"top_right": Vector2(1, -1),
			"bottom_left": Vector2(-1, 1),
			"bottom_right": Vector2(1, 1)
		}
	
		var adjacent_rooms := {}
		# check adjacent rooms
		for dir_key in directions.keys():
			var dir = directions[dir_key]
			adjacent_rooms[dir_key] = check_adjacent(room_rect, dir)

		# corridors
		if not adjacent_rooms["left"]:
			extend_border(tilemap, room_rect, "left")
		if not adjacent_rooms["right"]:
			extend_border(tilemap, room_rect, "right")
		if not adjacent_rooms["top"]:
			extend_border(tilemap, room_rect, "top")
		if not adjacent_rooms["bottom"]:
			extend_border(tilemap, room_rect, "bottom")
		# corners
		if not adjacent_rooms["left"] and not adjacent_rooms["top"]:
			extend_corner(tilemap, room_rect, "top_left")
		if not adjacent_rooms["right"] and not adjacent_rooms["top"]:
			extend_corner(tilemap, room_rect, "top_right")
		if not adjacent_rooms["left"] and not adjacent_rooms["bottom"]:
			extend_corner(tilemap, room_rect, "bottom_left")
		if not adjacent_rooms["right"] and not adjacent_rooms["bottom"]:
			extend_corner(tilemap, room_rect, "bottom_right")

func extend_corner(tilemap: TileMapLayer, room_rect: Rect2, corner_type: String):
	var top_left_coord = Rect2(-6, -6, corner_width, corner_height)
	var top_right_coord = Rect2(room_rect.size.x / scale_factor / tile_size + 1, -6, corner_width, corner_height)
	var bottom_left_coord = Rect2(-6, room_rect.size.y / scale_factor / tile_size + 1, corner_width, corner_height)
	var bottom_right_coord = Rect2(room_rect.size.x / scale_factor / tile_size + 1, room_rect.size.y / scale_factor / tile_size + 1, corner_width, corner_height)
	
	if corner_type == "top_left":
		#print("Corner: ", corner_type, " position: ", top_left_coord)
		for x in range(corner_width):
			for y in range(corner_height):
				var tile_position = Vector2i(top_left_coord.position.x + x, top_left_coord.position.y + y)
				#print("Top_Left ", tile_position)
				tilemap.set_cell(tile_position, 0, corridor_tile)
		var corner_start = Vector2i(top_left_coord.position.x - 1, top_left_coord.position.y - 1)
		for x in range(corner_width + 1):
			var tile_position = Vector2i(corner_start.x + x, corner_start.y)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))

	elif corner_type == "top_right":
		#print("Corner: ", corner_type, " position: ", top_right_coord)
		for x in range(corner_width):
			for y in range(corner_height):
				var tile_position = Vector2i(top_right_coord.position.x + x, top_right_coord.position.y + y)
				tilemap.set_cell(tile_position, 0, corridor_tile)
		var corner_start = Vector2i(top_right_coord.position.x, top_right_coord.position.y - 1)
		for x in range(corner_width + 1):
			var tile_position = Vector2i(corner_start.x + x, corner_start.y)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x + top_right_coord.size.x, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))

	elif corner_type == "bottom_left":
		#print("Corner: ", corner_type, " position: ", bottom_left_coord)
		for x in range(corner_width):
			for y in range(corner_height):
				var tile_position = Vector2i(bottom_left_coord.position.x + x, bottom_left_coord.position.y + y)
				tilemap.set_cell(tile_position, 0, corridor_tile)
		var corner_start = Vector2i(bottom_left_coord.position.x - 1, bottom_left_coord.position.y - 1)
		for x in range(corner_width + 1):
			var tile_position = Vector2i(corner_start.x + x, corner_start.y + bottom_left_coord.size.y + 1)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))

	elif corner_type == "bottom_right":
		#print("Corner: ", corner_type, " position: ", bottom_right_coord)
		for x in range(corner_width):
			for y in range(corner_height):
				var tile_position = Vector2i(bottom_right_coord.position.x + x, bottom_right_coord.position.y + y)
				tilemap.set_cell(tile_position, 0, corridor_tile)
		var corner_start = Vector2i(bottom_right_coord.position.x - 1, bottom_right_coord.position.y - 1)
		for x in range(corner_width + 2):
			var tile_position = Vector2i(corner_start.x + x, corner_start.y + bottom_right_coord.size.y + 1)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x + bottom_right_coord.size.x + 1, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, Vector2i(2,4))

func check_adjacent(room_rect: Rect2, dir: Vector2) -> bool:
	var check_position = room_rect.position + (dir * Vector2(room_rect.size.x + spacing, room_rect.size.y + spacing))
	var check_area = Rect2(check_position, room_rect.size)

	for other_room in rooms:
		if other_room != room_rect and other_room.intersects(check_area, true):
			return true
	return false

func extend_border(tilemap, room_rect: Rect2, direction: String):
	var room_start = tilemap.local_to_map(Vector2i(0, 0))
	var room_end = tilemap.local_to_map(Vector2i(room_rect.size.x / scale_factor, room_rect.size.y / scale_factor))
	
	# detect diagonal rooms
	var diagonals = detect_diagonal_rooms(room_rect, direction)
	#print("DIAGONALS: ", diagonals)
	
	if direction == "left":
		print("DIA: ", diagonals)
		var topleftstart = 0
		var bottomleftstart = 0
		
		if Vector2(-1, -1) in diagonals:
			topleftstart = 6
					
		if Vector2(-1, 1) in diagonals:
			bottomleftstart = -6

		for y in range(room_start.y, room_end.y + 1):
			for x_offset in range(-CORRIDOR_WIDTH, 0):
				if x_offset == -6:
					tilemap.set_cell(Vector2i(room_start.x + x_offset - 1, y + topleftstart + bottomleftstart), 0, Vector2i(2,4))
				tilemap.set_cell(Vector2i(room_start.x + x_offset, y), 0, corridor_tile)
				
	elif direction == "right":
		var toprightstart = 0
		var bottomrightstart = 0
		
		if Vector2(1, -1) in diagonals:
			toprightstart = 6
					
		if Vector2(1, 1) in diagonals:
			bottomrightstart = -6
						
		for y in range(room_start.y, room_end.y + 1):
			for x_offset in range(1, CORRIDOR_WIDTH + 1):
				if x_offset == 6:
					tilemap.set_cell(Vector2i(room_end.x + x_offset + 1, y + toprightstart + bottomrightstart), 0, Vector2i(2,4))
				tilemap.set_cell(Vector2i(room_end.x + x_offset, y), 0, corridor_tile)
				
	elif direction == "top":
		var leftstart = 0
		var rightstart = 0
		
		if Vector2(-1, -1) in diagonals:
			leftstart = 6
					
		if Vector2(1, -1) in diagonals:
			rightstart = -6
			
		for x in range(room_start.x, room_end.x + 1):
			for y_offset in range(-CORRIDOR_WIDTH, 0):
				if y_offset == -6:
					tilemap.set_cell(Vector2i(x + leftstart + rightstart, room_start.y + y_offset - 1), 0, Vector2i(2,4))
				tilemap.set_cell(Vector2i(x, room_start.y + y_offset), 0, corridor_tile)
				
	elif direction == "bottom":
		var leftstart = 0
		var rightstart = 0
		
		if Vector2(-1, 1) in diagonals:
			leftstart = 6
					
		if Vector2(1, 1) in diagonals:
			rightstart = -6
			
		for x in range(room_start.x, room_end.x + 1):
			for y_offset in range(1, CORRIDOR_WIDTH + 1):
				if y_offset == 6:
					tilemap.set_cell(Vector2i(x + leftstart + rightstart, room_end.y + y_offset + 1), 0, Vector2i(2,4))
				tilemap.set_cell(Vector2i(x, room_end.y + y_offset), 0, corridor_tile)
	
	#print("Room World Pos: ", room_rect.position)
	#print("Room World Size: ", room_rect.size)
	#print("Placing Corridor at Direction:", direction)
	#print("Corridor Start:", room_start, " End:", room_end)
	#print("##############################################")

func detect_diagonal_rooms(room_rect: Rect2, direction: String) -> Dictionary:
	var diagonal_offsets = {
		"left": [Vector2(-1, -1), Vector2(-1, 1)],
		"right": [Vector2(1, -1), Vector2(1, 1)],
		"top": [Vector2(-1, -1), Vector2(1, -1)],
		"bottom": [Vector2(-1, 1), Vector2(1, 1)]
	}
	
	var diagonals_found = {}
	for offset in diagonal_offsets.get(direction, []):
		var check_pos = room_rect.position + (offset * (room_rect.size + Vector2(spacing, spacing)))
		for room in rooms:
			if room.position == check_pos:
				diagonals_found[offset] = room
	
	return diagonals_found  # detected diagonal rooms
