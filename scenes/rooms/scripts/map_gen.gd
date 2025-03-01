extends Node2D

###########################################
# Simple Map Gen - Creates a random map layout of a building such as school.
# - main hall, cafe, gym, bathrooms, classrooms
# - outlines corridors and corners

# - emits map_gen signal when complete

# NOTE: the rooms prob should handle random object placements
###########################################
#E3C


@export var rooms_container: Node2D
@export var stim_spawner: StimSpanwer

const ROOM_TYPES := {
	"main_hall": {"scene": preload("res://scenes/rooms/main_hall_a.tscn"), "size": Vector2(60, 30)},
	"class_room": {"scene": preload("res://scenes/rooms/class_room_a.tscn"), "size": Vector2(60, 30)},
	"bath_room": {"scene": preload("res://scenes/rooms/bath_room_a.tscn"), "size": Vector2(60, 30)},
	"gym": {"scene": preload("res://scenes/rooms/gym_a.tscn"), "size": Vector2(60, 92)},
	"cafeteria": {"scene": preload("res://scenes/rooms/cafeteria_a.tscn"), "size": Vector2(60, 30)}
}

@export var class_room_num := 5
var rooms := []
@export var tile_size := 128
@export var scale_factor := 1
var previous_direction := Vector2.RIGHT  # store previous direction
@export var corridor_tile := Vector2i(0, 0)  # floor
@export var wall_tile := Vector2i(1, 0)  # floor
const CORRIDOR_WIDTH := 6  # 6 tiles wide
var corner_width = 6
var corner_height = 6

var gym_rect_compare := Rect2(0,0,0,0)

func _ready():
	generate_aligned_rooms()
	call_deferred("add_corridors")
	
	get_tree().create_timer(0.5).timeout.connect(spawn_assets)

func generate_aligned_rooms():
	var current_pos := Vector2(to_world_vectori(Vector2i(10, 10))) # starting position
	
	# place main hall
	var main_hall_data := ROOM_TYPES["main_hall"]
	var main_hall_size = to_world_vectori(main_hall_data["size"])
	
	var main_hall_rect := Rect2(current_pos, main_hall_size)
	rooms.append(main_hall_rect)
	spawn_room_instance(main_hall_rect, main_hall_data["scene"])
	
	var gym_data := ROOM_TYPES["gym"]
	var gym_size = to_world_vectori(gym_data["size"])
	var gym_rect = main_hall_rect
	var gym_pos = find_valid_position(gym_rect, gym_size)
	gym_rect = Rect2(gym_pos, gym_size)
	gym_rect_compare = gym_rect
	
	if gym_pos != Vector2.INF: # If a valid
		rooms.append(gym_rect)
		spawn_room_instance(gym_rect, gym_data["scene"])
		gym_rect.position = gym_pos
		#print("Gym placed at:", gym_pos)
	else:
		print("Failed to place Gym")
	
	var cafe_data := ROOM_TYPES["cafeteria"]
	var cafe_size = to_world_vectori(cafe_data["size"])
	var cafe_rect := main_hall_rect
	var cafe_pos = find_valid_position(cafe_rect, cafe_size)
	cafe_rect = Rect2(cafe_pos, cafe_size)
	
	if cafe_pos != Vector2.INF:
		rooms.append(cafe_rect)
		spawn_room_instance(cafe_rect, cafe_data["scene"])
		cafe_rect.position = cafe_pos
		#print("cafe placed at:", cafe_pos)
	else:
		print("Failed to place cafe")
		
		
	var bath_room_data := ROOM_TYPES["bath_room"]
	var bath_room_size = to_world_vectori(bath_room_data["size"])
	var bath_room_rect := main_hall_rect
	var bath_room_pos = find_valid_position(bath_room_rect, bath_room_size)
	bath_room_rect = Rect2(bath_room_pos, bath_room_size)
	
	if bath_room_pos != Vector2.INF:
		rooms.append(bath_room_rect)
		spawn_room_instance(bath_room_rect, bath_room_data["scene"])
		bath_room_rect.position = bath_room_pos
		#print("cafe placed at:", bath_room_pos)
	else:
		print("Failed to place bath_room")
	
	var possible_room_positions = [main_hall_rect, cafe_rect]
	var count = 0
	for i in range(class_room_num):
		var class_room_data = ROOM_TYPES["class_room"]
		var class_room_size = to_world_vectori(class_room_data["size"])
		var random_room = possible_room_positions[randi() % possible_room_positions.size()]
		var class_room_pos = find_valid_position(random_room, class_room_size)
		
		if class_room_pos != Vector2.INF:
			var class_room_rect = Rect2(class_room_pos, class_room_size)
			rooms.append(class_room_rect)
			spawn_room_instance(class_room_rect, class_room_data["scene"])
			possible_room_positions.clear()
			possible_room_positions.append(class_room_rect)
			#print("class room placed at:", class_room_pos)
			count = count + 1
		else:
			print("Failed to place class room")
		
		if count == class_room_num:
			
			var bath_room_data2 := ROOM_TYPES["bath_room"]
			var bath_room_size2 = to_world_vectori(bath_room_data2["size"])
			var bath_room_rect2 := Rect2(class_room_pos, class_room_size)
			var bath_room_pos2 = find_valid_position(bath_room_rect2, bath_room_size2)
			bath_room_rect2 = Rect2(bath_room_pos2, bath_room_size2)
	
			if bath_room_pos2 != Vector2.INF:
				rooms.append(bath_room_rect2)
				
				spawn_room_instance(bath_room_rect2, bath_room_data2["scene"])
				bath_room_rect2.position = bath_room_pos2
				#print("cafe placed at:", bath_room_pos)
			else:
				print("Failed to place bath_room2")

func find_valid_position(base_room: Rect2, room_size: Vector2) -> Vector2:
	var directions = [
		Vector2.RIGHT, 
		Vector2.LEFT, 
		Vector2.UP, 
		Vector2.DOWN
	]
	
	directions.shuffle()  # randomize
	
	for dir in directions:
		var new_pos = base_room.position + (dir * (base_room.size + Vector2((scale_factor * tile_size), (scale_factor * tile_size))))
		var new_room = Rect2(new_pos, room_size)
		
		if is_room_valid(new_room):
			return new_pos
	
	return Vector2.INF

func is_room_valid(room: Rect2) -> bool:
	for existing_room in rooms:
		if existing_room.intersects(room, true):
			return false  
	return true

func spawn_room_instance(room: Rect2, scene: PackedScene):
	var room_instance = scene.instantiate()
	room_instance.global_position = room.position
	rooms_container.call_deferred("add_child", room_instance)

func find_room_by_position(target_position: Vector2) -> Rect2:
	for room in rooms:
		if room.position == target_position:
			return room  # Return the found Rect2
	#print("No room found at:", target_position)
	return Rect2(0,0,0,0)

func add_corridors():
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
			"bottom_right": Vector2(1, 1),
			"middle_left": Vector2(-1, 0.5),
			"middle_right": Vector2(1, 0.5)
		}
	
		var adjacent_rooms := {}

		for dir_key in directions.keys():
			var dir = directions[dir_key]

			# special case for middle-left and middle-right
			if dir_key == "middle_left":
				var middle_left_pos = room_rect.position + Vector2(-(scale_factor * tile_size), room_rect.size.y / 2)
				adjacent_rooms[dir_key] = find_room_by_position(middle_left_pos)
			elif dir_key == "middle_right":
				var middle_right_pos = room_rect.position + Vector2(room_rect.size.x + (scale_factor * tile_size), room_rect.size.y / 2)
				adjacent_rooms[dir_key] = find_room_by_position(middle_right_pos)
			else:
				adjacent_rooms[dir_key] = check_adjacent(room_rect, dir)
				
				
		# corridors
		if not adjacent_rooms["left"]:
			extend_border(tilemap, room_rect, "left", room.name)
		if not adjacent_rooms["right"]:
			extend_border(tilemap, room_rect, "right" , room.name)
		if not adjacent_rooms["top"]:
			extend_border(tilemap, room_rect, "top" , room.name)
		if not adjacent_rooms["bottom"]:
			extend_border(tilemap, room_rect, "bottom" , room.name)
		if not adjacent_rooms["middle_left"]:
			extend_border(tilemap, room_rect, "middle_left", room.name)
		if not adjacent_rooms["middle_right"]:
			extend_border(tilemap, room_rect, "middle_right", room.name)

		# corners
		if not adjacent_rooms["left"] and not adjacent_rooms["top"]:
			extend_corner(tilemap, room_rect, "top_left")
		if not adjacent_rooms["right"] and not adjacent_rooms["top"]:
			extend_corner(tilemap, room_rect, "top_right")
		if not adjacent_rooms["left"] and not adjacent_rooms["bottom"]:
			extend_corner(tilemap, room_rect, "bottom_left")
		if not adjacent_rooms["right"] and not adjacent_rooms["bottom"]:
			extend_corner(tilemap, room_rect, "bottom_right")
			
	SignalBus.map_generated.emit()

func extend_corner(tilemap: TileMapLayer, room_rect: Rect2, corner_type: String):
	
	# make sure we use tilemap coords...most all coords are in world including sizes
	var top_left_coord = Rect2(-corner_width, -corner_height, corner_width, corner_height) # top left
	var top_right_coord = Rect2(to_tilemap_int(room_rect.size.x) + 1, -corner_height, corner_width, corner_height)
	var bottom_left_coord = Rect2(-corner_width, to_tilemap_int(room_rect.size.y) + 1, corner_width, corner_height)
	var bottom_right_coord = Rect2(to_tilemap_int(room_rect.size.x) + 1, to_tilemap_int(room_rect.size.y) + 1, corner_width, corner_height)
	
	if to_tilemap_int(room_rect.size.y) > 91: # if we have a gym return
		#print("Detected a ", name, " size: ", (room_rect.size / scale_factor / tile_size))
		return
	
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
			tilemap.set_cell(tile_position, 0, wall_tile)
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, wall_tile)

	elif corner_type == "top_right":
		#print("Corner: ", corner_type, " position: ", top_right_coord)
		for x in range(corner_width):
			for y in range(corner_height):
				var tile_position = Vector2i(top_right_coord.position.x + x, top_right_coord.position.y + y)
				tilemap.set_cell(tile_position, 0, corridor_tile)
				
		var corner_start = Vector2i(top_right_coord.position.x, top_right_coord.position.y - 1)
		for x in range(corner_width + 1):
			var tile_position = Vector2i(corner_start.x + x, corner_start.y)
			tilemap.set_cell(tile_position, 0, wall_tile)
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x + top_right_coord.size.x, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, wall_tile)

	elif corner_type == "bottom_left":
		#print("Corner: ", corner_type, " position: ", bottom_left_coord)
		for x in range(corner_width):
			for y in range(corner_height):
				var tile_position = Vector2i(bottom_left_coord.position.x + x, bottom_left_coord.position.y + y)
				tilemap.set_cell(tile_position, 0, corridor_tile)
		var corner_start = Vector2i(bottom_left_coord.position.x - 1, bottom_left_coord.position.y - 1)
		for x in range(corner_width + 1):
			var tile_position = Vector2i(corner_start.x + x, corner_start.y + bottom_left_coord.size.y + 1)
			tilemap.set_cell(tile_position, 0, wall_tile)
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, wall_tile)

	elif corner_type == "bottom_right":
		#print("Corner: ", corner_type, " position: ", bottom_right_coord)
		for x in range(corner_width):
			for y in range(corner_height):
				var tile_position = Vector2i(bottom_right_coord.position.x + x, bottom_right_coord.position.y + y)
				tilemap.set_cell(tile_position, 0, corridor_tile)
		var corner_start = Vector2i(bottom_right_coord.position.x - 1, bottom_right_coord.position.y - 1)
		for x in range(corner_width + 2):
			var tile_position = Vector2i(corner_start.x + x, corner_start.y + bottom_right_coord.size.y + 1)
			tilemap.set_cell(tile_position, 0, wall_tile)
		for y in range(corner_height + 1):
			var tile_position = Vector2i(corner_start.x + bottom_right_coord.size.x + 1, corner_start.y + y)
			tilemap.set_cell(tile_position, 0, wall_tile)

func check_adjacent(room_rect: Rect2, dir: Vector2) -> bool:
	# have to check in world coords
	var check_position = room_rect.position + (dir * Vector2(room_rect.size.x + (scale_factor * tile_size), room_rect.size.y + (scale_factor * tile_size)))
	var check_area = Rect2(check_position, room_rect.size)

	for other_room in rooms:
		if other_room != room_rect and other_room.intersects(check_area, true):
			return true
	return false

func extend_border(tilemap, room_rect: Rect2, direction: String, name: String):
	# again we are in tilemap coords
	var room_start = Vector2i(0, 0)
	var room_end = Vector2i(to_tilemap_int(room_rect.size.x), to_tilemap_int(room_rect.size.y))
	
	# detect diagonal rooms in world coords
	var diagonals = detect_diagonal_rooms(room_rect, direction)
	#print("Diagonals found:", diagonals)
	
	if to_tilemap_int(room_rect.size.y) > 91: # if gym return
		#print("Detected a ", name, " size: ", (room_rect.size / scale_factor / tile_size))
		return
	
	if direction == "left":
		var toprightstart = 0
		var bottomrightstart = 0
		for y in range(room_start.y, room_end.y + 1):
			for x_offset in range(-CORRIDOR_WIDTH, 0):
				
				# do walls
				if Vector2(-1, -1) in diagonals: # left side
					toprightstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(-1, -1))).position:
						toprightstart = toprightstart - 6
					#print(name, " left left side ", y + toprightstart)
					if x_offset == -CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(room_start.x + x_offset - 1, y + toprightstart), 0, wall_tile)
				elif Vector2(-1, 1) in diagonals: # right side
					bottomrightstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(-1, 1))).position:
						bottomrightstart = bottomrightstart - 6
					#print(name, " left right side ", y - bottomrightstart)
					if x_offset == -CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(room_start.x + x_offset - 1, y - bottomrightstart), 0, wall_tile)
				else:
					#print(name, " left full ", y)
					if x_offset == -CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(room_start.x + x_offset - 1, y), 0, wall_tile)
				# do floors
				tilemap.set_cell(Vector2i(room_start.x + x_offset, y), 0, corridor_tile)

	elif direction == "right":
		var toprightstart = 0
		var bottomrightstart = 0
		for y in range(room_start.y, room_end.y + 1):
			for x_offset in range(1, CORRIDOR_WIDTH + 1):
				
				# do walls
				if Vector2(1, -1) in diagonals: # left side
					toprightstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(1, -1))).position:
						toprightstart = toprightstart - 6
					#print(name, " right left side ", y + toprightstart)
					if x_offset == CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(room_end.x + x_offset + 1, y + toprightstart), 0, wall_tile)
				elif Vector2(1, 1) in diagonals: # right side
					bottomrightstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(1, 1))).position:
						bottomrightstart = bottomrightstart - 6
					#print(name, " right right side ", y - bottomrightstart)
					if x_offset == CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(room_end.x + x_offset + 1, y - bottomrightstart), 0, wall_tile)
				else:
					#print(name, " right full ", y)
					if x_offset == CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(room_end.x + x_offset + 1, y), 0, wall_tile)
				# do floors
				tilemap.set_cell(Vector2i(room_end.x + x_offset, y), 0, corridor_tile)

	elif direction == "top":
		var leftstart = 0
		var rightstart = 0
		for x in range(room_start.x, room_end.x + 1):
			for y_offset in range(-CORRIDOR_WIDTH, 0):
				
				# do walls
				if Vector2(-1, -1) in diagonals: # left side
					leftstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(-1, -1))).position:
						leftstart = leftstart - 6
					#print(name, " top left side ", x + leftstart)
					if y_offset == -CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(x + leftstart, room_start.y + y_offset - 1), 0, wall_tile)
				elif Vector2(1, -1) in diagonals: # right side
					rightstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(1, -1))).position:
						rightstart = rightstart - 6
					#print(name, " top right side ", x - rightstart)
					if y_offset == -CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(x - rightstart, room_start.y + y_offset - 1), 0, wall_tile)
				else:
					#print(name, " top full ", x)
					if y_offset == -CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(x, room_start.y + y_offset - 1), 0, wall_tile)
				# do floors
				tilemap.set_cell(Vector2i(x, room_start.y + y_offset), 0, corridor_tile)

	elif direction == "bottom":
		var leftstart = 0
		var rightstart = 0
		for x in range(room_start.x, room_end.x + 1):
			for y_offset in range(1, CORRIDOR_WIDTH + 1):
				
				# do walls
				if Vector2(-1, 1) in diagonals: # left side
					leftstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(-1,1))).position:
						leftstart = leftstart - 6
					#print(name, " bottom left side ", x + leftstart)
					if y_offset == CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(x + leftstart, room_end.y + y_offset + 1), 0, wall_tile)
				elif Vector2(1, 1) in diagonals: # right side
					rightstart = corner_width
					if gym_rect_compare.position == diagonals.get((Vector2(1,1))).position:
						rightstart = rightstart - 6
					#print(name, " bottom right side ", x + rightstart)
					if y_offset == CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(x - rightstart, room_end.y + y_offset + 1), 0, wall_tile)
				else:
					#print(name, " bottom full ", x)
					if y_offset == CORRIDOR_WIDTH:
						tilemap.set_cell(Vector2i(x, room_end.y + y_offset + 1), 0, wall_tile)
				# do floors
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
		# Calculate diagonal position
		var check_pos = room_rect.position + (offset * (room_rect.size + Vector2((scale_factor * tile_size), (scale_factor * tile_size))))
		var check_rect = Rect2(check_pos, room_rect.size)
		
		# Find overlapping rooms
		for room in rooms:
			if check_rect.intersects(room):
				diagonals_found[offset] = room
				
	return diagonals_found

func to_tilemap_int(value: int) -> int:
	value = value / scale_factor / tile_size
	return value
	
func to_tilemap_vectori(value: Vector2i) -> Vector2i:
	value.x = value.x / scale_factor / tile_size
	value.y = value.y / scale_factor / tile_size
	return value

func to_world_vectori(value: Vector2i) -> Vector2i:
	value.x = value.x * scale_factor * tile_size
	value.y = value.y * scale_factor * tile_size
	return value

func spawn_assets():
	for room in rooms_container.get_children():
		var tile_map_layer = room.get_node("Nodes").get_node("floor") as TileMapLayer
		stim_spawner.tile_map_layer = tile_map_layer
		stim_spawner.spawn_stims()
