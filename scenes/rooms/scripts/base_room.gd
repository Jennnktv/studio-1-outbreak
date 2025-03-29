extends Node
class_name base_room

# WHAT IM THINKING
	#print("Check Top for a Room. ")
			# if we find a room here we need to trim the whole top or skip other top checks here. no top corridor and just dont add
				# no top? lets now check the top left corner. if we find something, lets set topleftstart = 3,-3 (inside facing corner) else it might be
					# outside a corner. lets check the left side for a room. if we dont get a room on left, its a true corner, set topleftstart = -3,-3.
					# else if it finds something there on left, its a straight, set topleftstart = 0,-3
						# lets now check the top right. if we find something, lets set toprightend = 57,-3 (inside facing corner)
							# else it a corner. lets check right side for a room, if we dont get a right that means its a corner. set toprightend = 63, -3
								# else if it finds something there on right, its a straight, set topleftend = 60,-3 


# this class has some hard coded vars, need to clean it up later


@onready var map_gen: Node2D
@onready var rooms_container: Node2D
@onready var tilemap := $Nodes/floor as TileMapLayer

@onready var room_center: Vector2
@onready var tile_size := 128
@onready var width := 60
@onready var height := 30

func _ready() -> void:
	rooms_container = get_parent()
	
	room_center.x = self.global_position.x + width / 2 * tile_size
	room_center.y = self.global_position.y + height / 2 * tile_size
	
	#print(name, " Non Center: ", self.global_position, " Room Center: ", room_center)

func gen_corridors():
	if name == "gym_a": 
		return

	# default corridor trimming positions for TOP
	var top_start = Vector2i(0, -6)
	var top_end = Vector2i(width, -6)
	
	# bheck for a room above
	var top = check_for_room(Vector2(0, -1))
	if !top:
		# check topleft corner
		var top_left = check_for_room(Vector2(-1, -1))
		if top_left:
			top_start = Vector2i(5, -6)
		else:
			@warning_ignore("confusable_local_declaration")
			var left = check_for_room(Vector2(-1, 0))
			top_start = Vector2i(-6, -6) if !left else Vector2i(0, -6)  # true outside corner or straight edge
		
		# check topright corner
		var top_right = check_for_room(Vector2(1, -1))
		if top_right:
			top_end = Vector2i(width - 5, -6)
		else:
			@warning_ignore("confusable_local_declaration")
			var right = check_for_room(Vector2(1, 0))
			top_end = Vector2i(width + 6, -6) if !right else Vector2i(width, -6)

		# modify top walls and floors
		for x in range(top_start.x, top_end.x + 1):
			tilemap.set_cell(Vector2i(x, -6), 1, Vector2i(2, 0))
			if top_start == Vector2i(5, -6):
				tilemap.set_cell(Vector2i(5, -6), 1, Vector2i(2, 1))
			if top_end == Vector2i(width - 5, -6):
				tilemap.set_cell(Vector2i(width - 5, -6), 1, Vector2i(3, 1))
		
		for x in range(top_start.x, top_end.x + 1):
			for y in range(-5, 0):
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
				

	# default corridor trimming positions for BOTTOM
	var bottom_start = Vector2i(0, height + 6)
	var bottom_end = Vector2i(width, height + 6)

	# check for a room below
	var bottom = check_for_room(Vector2(0, 1))
	if !bottom:
		# check bottom left corner
		var bottom_left = check_for_room(Vector2(-1, 1))
		if bottom_left:
			bottom_start = Vector2i(5, height + 6)
		else:
			@warning_ignore("confusable_local_declaration")
			var left = check_for_room(Vector2(-1, 0))
			bottom_start = Vector2i(-6, height + 6) if !left else Vector2i(0, height + 6)
	
		# check bottom right corner
		var bottom_right = check_for_room(Vector2(1, 1))
		if bottom_right:
			bottom_end = Vector2i(width - 5, height + 6)
		else:
			@warning_ignore("confusable_local_declaration")
			var right = check_for_room(Vector2(1, 0))
			bottom_end = Vector2i(width + 6, height + 6) if !right else Vector2i(width, height + 6)

		# modify bottom walls and floors
		for x in range(bottom_start.x, bottom_end.x + 1):
			tilemap.set_cell(Vector2i(x, height + 6), 1, Vector2i(2, 0))
			if bottom_start == Vector2i(5, height + 6):
				tilemap.set_cell(Vector2i(5, height + 6), 1, Vector2i(1, 0))
			if bottom_end == Vector2i(width - 5, height + 6):
				tilemap.set_cell(Vector2i(width - 5, height + 6), 1, Vector2i(3, 0))
			
		for x in range(bottom_start.x, bottom_end.x + 1):
			for y in range(height + 1, height + 6):
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

	# default corridor trimming positions for LEFT
	var left_start = Vector2i(-6, 0)
	var left_end = Vector2i(-6, height)

	# check for a room to the left
	var left = check_for_room(Vector2(-1, 0))
	if !left:
		# topleft corner
		var top_left = check_for_room(Vector2(-1, -1))
		if top_left:
			left_start = Vector2i(-6, 6)
		else:
			var top1 = check_for_room(Vector2(0, -1))
			left_start = Vector2i(-6, -6) if !top1 else Vector2i(-6, 0)
	
		# bottomleft corner
		var bottom_left = check_for_room(Vector2(-1, 1))
		if bottom_left:
			left_end = Vector2i(-6, height - 6)
		else:
			var bottom1 = check_for_room(Vector2(0, 1))
			left_end = Vector2i(-6, height + 6) if !bottom1 else Vector2i(-6, height)

		# left walls and floors
		for y in range(left_start.y, left_end.y + 1):
			tilemap.set_cell(Vector2i(-6, y), 1, Vector2i(0, 0))
		for y in range(left_start.y, left_end.y + 1):
			for x in range(-5, 0):
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

	# Default corridor trimming positions for RIGHT
	var right_start = Vector2i(width + 6, 0)
	var right_end = Vector2i(width + 6, height)

	# for a room to the right
	var right = check_for_room(Vector2(1, 0))
	if !right:
		# topright corner
		var top_right = check_for_room(Vector2(1, -1))
		if top_right:
			right_start = Vector2i(width + 6, 6)
		else:
			var top2 = check_for_room(Vector2(0, -1))
			right_start = Vector2i(width + 6, -6) if !top2 else Vector2i(width + 6, 0)
	
		# bottomright corner
		var bottom_right = check_for_room(Vector2(1, 1))
		if bottom_right:
			right_end = Vector2i(width + 6, height - 6)
		else:
			var bottom1 = check_for_room(Vector2(0, 1))
			right_end = Vector2i(width + 6, height + 6) if !bottom1 else Vector2i(width + 6, height)

		# right walls and floors
		for y in range(right_start.y, right_end.y + 1):
			tilemap.set_cell(Vector2i(width + 6, y), 1, Vector2i(0, 0))
		for y in range(right_start.y, right_end.y + 1):
			for x in range(width + 1, width + 6):
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	# lets try and button up the corners
	#tilemap.set_cell(Vector2i(6,-6), 0, Vector2i(1, 0))
	var data = tilemap.get_cell_tile_data(Vector2i(-1,-3)) # top left corners
	if data:
		tilemap.set_cell(Vector2i(-6, -6), 1, Vector2i(1, 0)) # top left corner tile only
		for i in 6:
			tilemap.set_cell(Vector2i(-i, -6), 1, Vector2i(2, 0))

	var data1 = tilemap.get_cell_tile_data(Vector2i(width + 1, -3)) # top right corners
	if data1:
		tilemap.set_cell(Vector2i(width + 6, -6), 1, Vector2i(3, 0)) # top right corner tile only
		for i in 6:
			tilemap.set_cell(Vector2i(width + i, -6), 1, Vector2i(2, 0))

	var data2 = tilemap.get_cell_tile_data(Vector2i(-1, height + 3)) # left bottom corners
	#tilemap.set_cell(Vector2i(0, height + 6), 0, Vector2i(-1, -1))
	if data2:
		tilemap.set_cell(Vector2i(-6, height + 6), 1, Vector2i(2, 1)) # bottom left corner tile only
		for i in 6:
			tilemap.set_cell(Vector2i(-i, height + 6), 1, Vector2i(2, 0))

	var data3 = tilemap.get_cell_tile_data(Vector2i(width + 1, height + 3)) # right bottom corners
	if data3:
		tilemap.set_cell(Vector2i(width + 6, height + 6), 1, Vector2i(3, 1)) # bottom left corner tile only
		for i in 6:
			tilemap.set_cell(Vector2i(width + i, height + 6), 1, Vector2i(2, 0))
			
	
	var atlas_coords = tilemap.get_cell_atlas_coords(Vector2i(-1, height)) # left bottom
	var atlas_coords1 = tilemap.get_cell_atlas_coords(Vector2i(-1, 0)) # left top
	if atlas_coords == Vector2i(-1,-1) and !left:
		#print(name, " ", atlas_coords, " dir: ", left, " has inside corner.")
		for x in 5:
			for y in 6:
				tilemap.set_cell(Vector2i(x - 5, y + height - 5), 0, Vector2i(0, 0))
	if atlas_coords1 == Vector2i(-1,-1) and !left:
		#print(name, " ", atlas_coords, " dir: ", left, " has inside corner.")
		for x in 5:
			for y in 6:
				tilemap.set_cell(Vector2i(x - 5, y), 0, Vector2i(0, 0))
	
	atlas_coords = tilemap.get_cell_atlas_coords(Vector2i(width + 1, height)) # right bottom
	atlas_coords1 = tilemap.get_cell_atlas_coords(Vector2i(width + 1, 0)) # right top
	if atlas_coords == Vector2i(-1,-1) and !right:
		#print(name, " ", atlas_coords, " dir: ", right, " has inside corner.")
		#tilemap.set_cell(Vector2i(width + 1, height), 1, Vector2i(-1, -1))
		for x in 5:
			for y in 6:
				tilemap.set_cell(Vector2i(width + x + 1, y + height - 5), 0, Vector2i(0, 0))
	if atlas_coords1 == Vector2i(-1,-1) and !right:
		#print(name, " ", atlas_coords, " dir: ", right, " has inside corner.")
		for x in 5:
			for y in 6:
				tilemap.set_cell(Vector2i(width + x + 1, y), 0, Vector2i(0, 0))
	
	#print("finished base")
	
	map_gen = get_parent().get_parent().get_node_or_null("Map_Gen")
	
	if map_gen.room_to_edit == tilemap:
		cut_out_gym_other_room_corridor()

func check_for_room(dir: Vector2) -> bool:
	# calculate the check position
	var check_position = self.global_position + (dir * Vector2(width * tile_size, height * tile_size))
	var check_area = Rect2(check_position, Vector2(width * tile_size, height * tile_size))
	
	#print("Checking for room at: ", check_area.position, " with size: ", check_area.size, " dir: ", dir)

	for other_room in rooms_container.get_children():
		if other_room == self:
			continue  # skip self-check
		
		var other_area = Rect2(other_room.global_position, Vector2(other_room.width * other_room.tile_size, other_room.height * other_room.tile_size))
		#print("Comparing with room at: ", other_area.position, " with size: ", other_area.size)

		if check_area.intersects(other_area):
			#print("Room found!")
			return true  # Room is found
	#print("No room found.")
	return false

func cut_out_gym_other_room_corridor():
	#print("start cutout")
	
	tilemap.set_cell(Vector2i(28, 36), 1, Vector2i(3, 0)) # first open corner
	tilemap.set_cell(Vector2i(29, 36), 0, Vector2i(0, 0)) # open up the corridor for the other room
	tilemap.set_cell(Vector2i(30, 36), 0, Vector2i(0, 0)) # open up the corridor for the other room
	tilemap.set_cell(Vector2i(31, 36), 0, Vector2i(0, 0)) # open up the corridor for the other room
	tilemap.set_cell(Vector2i(32, 36), 0, Vector2i(0, 0)) # open up the corridor for the other room
	tilemap.set_cell(Vector2i(33, 36), 1, Vector2i(1, 0)) # second open corner
