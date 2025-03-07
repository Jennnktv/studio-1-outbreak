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

@export var class_room_num := 10
var rooms := []
@export var tile_size := 128
@export var scale_factor := 1
var previous_direction := Vector2.RIGHT  # store previous direction
@export var corridor_tile := Vector2i(0, 0)  # floor
@export var wall_tile := Vector2i(1, 0)  # wall
const CORRIDOR_WIDTH := 6  # 6 tiles wide
var corner_width = 6
var corner_height = 6

var room_to_edit = null

func _ready():
	generate_aligned_rooms()
	call_deferred("place_gym")
	get_tree().create_timer(0.5).timeout.connect(spawn_assets)

func generate_aligned_rooms():
	var current_pos := Vector2(to_world_vectori(Vector2i(10, 10))) # starting position
	
	# place main hall
	var main_hall_data := ROOM_TYPES["main_hall"]
	var main_hall_size = to_world_vectori(main_hall_data["size"])
	
	var main_hall_rect := Rect2(current_pos, main_hall_size)
	rooms.append(main_hall_rect)
	spawn_room_instance(main_hall_rect, main_hall_data["scene"])
	#print(main_hall_rect)

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

func find_valid_position(base_room1: Rect2, room_size: Vector2) -> Vector2:
	var directions = [
		Vector2.RIGHT, 
		Vector2.LEFT, 
		Vector2.UP, 
		Vector2.DOWN
	]
	
	directions.shuffle()  # randomize
	
	for dir in directions:
		var new_pos = base_room1.position + (dir * (base_room1.size + Vector2((scale_factor * tile_size), (scale_factor * tile_size))))
		var new_room = Rect2(new_pos, room_size)
		
		if is_room_valid(new_room):
			return new_pos
	
	return Vector2.INF

func is_room_valid(room: Rect2) -> bool:
	for existing_room in rooms:
		if existing_room.intersects(room, true):
			return false  
	return true

func spawn_room_instance(room: Rect2, scene: PackedScene) -> Node2D:
	var room_instance = scene.instantiate()
	room_instance.global_position = room.position
	rooms_container.call_deferred("add_child", room_instance)
	return room_instance

func find_room_by_position(target_position: Vector2) -> Rect2:
	for room in rooms:
		if room.position == target_position:
			return room  # Return the found Rect2
	#print("No room found at:", target_position)
	return Rect2(0,0,0,0)

func check_adjacent(room_rect: Rect2, dir: Vector2) -> bool:
	# have to check in world coords
	var check_position = room_rect.position + (dir * Vector2(room_rect.size.x + (scale_factor * tile_size), room_rect.size.y + (scale_factor * tile_size)))
	var check_area = Rect2(check_position, room_rect.size)

	for other_room in rooms:
		if other_room != room_rect and other_room.intersects(check_area, true):
			return true
	return false

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

func place_gym():
	var outer_rooms = get_outermost_rooms()
	if outer_rooms.is_empty():
		print("No valid outer rooms found!")
		return
	
	var gym_data := ROOM_TYPES["gym"]
	var gym_size = to_world_vectori(gym_data["size"])
	
	var directions = outer_rooms.keys()
	directions.shuffle()  

	for direction in directions:
		var other_room = outer_rooms[direction]
		var gym_pos = other_room.position

		var half_offset = Vector2(other_room.size.x / 2, other_room.size.y / 2)

		match direction:
			"north": gym_pos += Vector2(0, -half_offset.y - gym_size.y / 2)
			"south": gym_pos += Vector2(0, half_offset.y + gym_size.y / 2)
			"east": gym_pos += Vector2(half_offset.x + gym_size.x / 2, 0)
			"west": gym_pos += Vector2(-half_offset.x - gym_size.x / 2, 0)

		var gym_rect = Rect2(gym_pos, gym_size)
		if is_room_valid(gym_rect):
			rooms.append(gym_rect)
			var gym_instance = spawn_room_instance(gym_rect, gym_data["scene"])
			var gym_tilemap = gym_instance.get_node("Nodes").get_node("floor") as TileMapLayer
			
			#print(other_room)
			
			# find the closest room and its tilemap
			var other = get_room_node_by_position(other_room.position)
			room_to_edit = other.get_node("Nodes").get_node("floor") as TileMapLayer
			
			# now that we have both tilemaps, let's print them to confirm
			#print("Gym TileMap:", gym_tilemap)
			#print("Other Room TileMap:", room_to_edit)
			
			# now connect the centers
			var gym_center = gym_pos + Vector2(60, 92) / 2
			var other_center = other_room.position + Vector2(60, 30) / 2
			
			#print("Centers: gym: ", gym_center, " other: ", other_center, " ", other.name)
			
			# draw corridor between the centers
			create_corridor(gym_center, other_center, gym_tilemap)

			#print("Gym placed at:", gym_pos)
			return

	print("Failed to place Gym. Checked positions:", directions)

func get_room_node_by_position(position1: Vector2) -> Node2D:
	for room in rooms_container.get_children():
		if room.global_position == position1:
			return room
	return null

func get_outermost_rooms() -> Dictionary:
	var outer_rooms = {}
	
	if rooms.is_empty():
		return outer_rooms

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	var north_room = null
	var south_room = null
	var east_room = null
	var west_room = null

	for room in rooms:
		if room.position.y < min_y:
			min_y = room.position.y
			north_room = room
		if room.position.y > max_y:
			max_y = room.position.y
			south_room = room
		if room.position.x < min_x:
			min_x = room.position.x
			west_room = room
		if room.position.x > max_x:
			max_x = room.position.x
			east_room = room
	
	if north_room: outer_rooms["north"] = north_room
	if south_room: outer_rooms["south"] = south_room
	if east_room: outer_rooms["east"] = east_room
	if west_room: outer_rooms["west"] = west_room

	return outer_rooms

@warning_ignore("integer_division")
func create_corridor(start: Vector2, end: Vector2, gym_tilemap: TileMapLayer):
	var corridor_width = 5

# calculate the direction from the gym to the other room
	var direction = (end - start).normalized()

	# define how far the corridor should extend
	var corridor_length = 23  # Set the length of the corridor

	# start placing tiles in the gym tilemap
	for i in range(corridor_length):
		# move in the direction from gym center
		var current_pos = Vector2i(30, 0) + Vector2i(direction.x, direction.y) * i

		# place corridor tiles in a width of corridor_width
		for x in range(-corridor_width / 2 + 1, corridor_width / 2 + 1):
			for y in range(-corridor_width / 2, corridor_width / 2 + 1):
				var tile_pos = Vector2i(current_pos.x + x, current_pos.y + y)
				gym_tilemap.set_cell(tile_pos, 0, corridor_tile)  #set corridor tile in gym tilemap

@warning_ignore("integer_division")
func to_tilemap_int(value: int) -> int:
	value = value / scale_factor / tile_size
	return value

@warning_ignore("integer_division")
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
