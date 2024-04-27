extends Node
## Generates a 2d array map

# Modify to change level generation
var room_multiplier := 0.9			# Multiplier for number of rooms
var random_direction_hall := 0.10	# % Chance for a hall to go in a random direction
var opposite_direction_hall := 0.10	# % Chance for a hall to go in the opposite direction

# Other variables
var map_array := []						# 2d Array of room types
var map_size: int						# X and Y size of the map
var rng := RandomNumberGenerator.new()	# Godot's rng system


# Generate a 2d array of a map
func generate_map_array(level_seed):
	# Get variables for the level name and modifier
	map_size = LevelParameters.map_size
	
	# Create a 2d array for the map
	for n in map_size+2:
		map_array.append([])
		for m in map_size+2:
			(map_array[n] as Array).append("-")
	for n in range(1, map_size+1):
		for m in range(1, map_size+1):
			map_array[n][m] = "."
	
	# Set elevator in the middle of the map
	var start_y := map_size/2 + 1
	var start_x := map_size/2 + 1
	map_array[start_y][start_x] = "E"
	
	# Use the level seed supplied
	rng.seed = level_seed
	
	# Generate rooms and halls
	generate_rooms(start_y, start_x)
	
	# Rename the rooms and halls for loading the map
	for n in range(1, map_size+1):
		for m in range(1, map_size+1):
			if map_array[m][n] == "R" or map_array[m][n] == "H":
				rename_room_hall(m, n)


# Generate rooms using ValidRoom() + GenerateHall()
func generate_rooms(start_y, start_x):
	# Room variables
	var rooms := 0
	var room_y: int
	var room_x: int
	var failed_times := 0 # The following while loop could be stuck forever
	# Generate room and hall
	while rooms < (map_size * room_multiplier):
		room_y = rng.randi_range(1, map_size)
		room_x = rng.randi_range(1, map_size)
		if valid_room(room_y, room_x) == true:
			map_array[room_y][room_x] = "R"
			rooms += 1
			failed_times = 0
			generate_hall(room_y, room_x, start_y, start_x)
		else:
			failed_times += 1
		if (failed_times >= 1000): # If stuck, just continue with less rooms
			rooms += 1


# Function to check if a location for a room is valid
func valid_room(y, x) -> bool:
	if (map_array[y][x] == "." and
			(map_array[y+1][x] == "." or map_array[y+1][x] == "-") and
			(map_array[y-1][x] == "." or map_array[y-1][x] == "-") and
			(map_array[y][x+1] == "." or map_array[y][x+1] == "-") and
			(map_array[y][x-1] == "." or map_array[y][x-1] == "-")):
		return true
	else:
		return false


# Generate halls from a room
func generate_hall(y, x, start_y, start_x):
	# RNG variables
	var route := rng.randf_range(0.0, 1.0)
	var direction := rng.randi_range(1, 4)
	# Random direction hall
	if (route <= random_direction_hall and
			y < map_size and y > 0 and x < map_size and x > 0):
		if direction == 1 and map_array[y+1][x] == ".":
			y += 1
		elif direction == 2 and map_array[y-1][x] == ".":
			y += -1
		elif direction == 3 and map_array[y][x+1] == ".":
			x += 1
		elif direction == 4 and map_array[y][x-1] == ".":
			x += -1
	# Opposite direction hall
	elif (route <= random_direction_hall + opposite_direction_hall and
			y < map_size and y > 0 and x < map_size and x > 0):
		if (y - start_y) > 0:
			y += 1
		elif (y - start_y) < 0:
			y -= 1
		elif (x - start_x) > 0:
			x += 1
		elif (x - start_x) < 0:
			x -= 1
	# Correct direction hall (with rng)
	elif (y - start_y) >= 0 and direction == 1:
		y -= 1
	elif (y - start_y) <= 0 and direction == 2:
		y += 1
	elif (x - start_x) >= 0 and direction == 3:
		x -= 1
	elif (x - start_x) <= 0 and direction == 4:
		x += 1
	# If it made it back to the start or to a hallway
	if (y == start_y and x == start_x) or map_array[y][x] == "H":
		pass
	else:
		generate_hall(y, x, start_y, start_x)
	# Checks if the location is valid for a hall
	if map_array[y][x] == ".":
		map_array[y][x] = "H"


# Rename rooms and halls based on connections using NumberOfConnections()
func rename_room_hall(y, x):
	# 1 connection
	if number_of_connections(y, x) == 1:
		if map_array[y+1][x] != "." and map_array[y+1][x] != "-":
			if map_array[y][x] == "H":
				map_array[y][x] = "H1S"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R1S"
		elif map_array[y-1][x] != "." and map_array[y-1][x] != "-":
			if map_array[y][x] == "H":
				map_array[y][x] = "H1N"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R1N"
		elif map_array[y][x+1] != "." and map_array[y][x+1] != "-":
			if map_array[y][x] == "H":
				map_array[y][x] = "H1E"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R1E"
		elif map_array[y][x-1] != "." and map_array[y][x-1] != "-":
			if map_array[y][x] == "H":
				map_array[y][x] = "H1W"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R1W"
	# 2 connections
	elif number_of_connections(y, x) == 2:
		if (map_array[y+1][x] != "." and map_array[y+1][x] != "-" and
				map_array[y-1][x] != "." and map_array[y-1][x] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H2V"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R2V"
		elif (map_array[y][x+1] != "." and map_array[y][x+1] != "-" and
				map_array[y][x-1] != "." and map_array[y][x-1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H2H"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R2H"
		elif (map_array[y+1][x] != "." and map_array[y+1][x] != "-" and
				map_array[y][x+1] != "." and map_array[y][x+1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H2SE"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R2SE"
		elif (map_array[y+1][x] != "." and map_array[y+1][x] != "-" and
				map_array[y][x-1] != "." and map_array[y][x-1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H2SW"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R2SW"
		elif (map_array[y-1][x] != "." and map_array[y-1][x] != "-" and
				map_array[y][x+1] != "." and map_array[y][x+1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H2NE"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R2NE"
		elif (map_array[y-1][x] != "." and map_array[y-1][x] != "-" and
				map_array[y][x-1] != "." and map_array[y][x-1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H2NW"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R2NW"
	# 3 connections
	elif number_of_connections(y, x) == 3:
		if (map_array[y+1][x] != "." and map_array[y+1][x] != "-" and
				map_array[y][x+1] != "." and map_array[y][x+1] != "-" and
				map_array[y][x-1] != "." and map_array[y][x-1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H3N"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R3N"
		elif (map_array[y+1][x] != "." and map_array[y+1][x] != "-" and
				map_array[y-1][x] != "." and map_array[y-1][x] != "-" and
				map_array[y][x-1] != "." and map_array[y][x-1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H3E"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R3E"
		elif (map_array[y-1][x] != "." and map_array[y-1][x] != "-" and
				map_array[y][x+1] != "." and map_array[y][x+1] != "-" and
				map_array[y][x-1] != "." and map_array[y][x-1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H3S"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R3S"
		elif (map_array[y+1][x] != "." and map_array[y+1][x] != "-" and
				map_array[y-1][x] != "." and map_array[y-1][x] != "-" and
				map_array[y][x+1] != "." and map_array[y][x+1] != "-"):
			if map_array[y][x] == "H":
				map_array[y][x] = "H3W"
			elif map_array[y][x] == "R":
				map_array[y][x] = "R3W"
	# 4 connections
	elif number_of_connections(y, x) == 4:
		if map_array[y][x] == "H":
			map_array[y][x] = "H4"
		elif map_array[y][x] == "R":
			map_array[y][x] = "R4"
	# 0 connections (something went wrong)
	elif number_of_connections(y, x) == 0:
		if map_array[y][x] == "H":
			map_array[y][x] = "H0"
		elif map_array[y][x] == "R":
			map_array[y][x] = "R0"


# Counts the number of connections from a given index
func number_of_connections(y, x):
	var num:int = 0
	if map_array[y+1][x] != "." and map_array[y+1][x] != "-":
		num += 1
	if map_array[y-1][x] != "." and map_array[y-1][x] != "-":
		num += 1
	if map_array[y][x+1] != "." and map_array[y][x+1] != "-":
		num += 1
	if map_array[y][x-1] != "." and map_array[y][x-1] != "-":
		num += 1
	return num
