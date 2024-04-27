extends Node2D
## Generates a level

enum RoomPatterns {EMPTY, H0, R0, H1N, H1E, H1S, H1W, H2V, H2H,
		H2NE, H2SE, H2SW, H2NW, H3N, H3E, H3S, H3W, H4,
		R1N, R1E, R1S, R1W, R2V, R2H, R2NE, R2SE, R2SW, R2NW,
		R3N, R3E, R3S, R3W, R4}
var tile_length := 32								# Length of each tile in pixels
var room_tile_length := 16							# Number of tiles that make up a room pattern
var room_spacing = tile_length * room_tile_length	# How spread out the rooms are
var rng = RandomNumberGenerator.new()
@onready var LevelFloor: TextureRect = %LevelFloor
@onready var LevelTileMap: TileMap = %LevelTileMap
@onready var Elevator: Node2D = %Elevator
@onready var Player: CharacterBody2D = %Player


func generate_level(level_name, modifier):
	rng.randomize()
	
	RunStats.level_number += 1
	
	LevelParameters.set_level_parameters(level_name, modifier)
	
	var Map := preload("res://src/scripts/map_array_generation.gd").new()
	await Map.generate_map_array(rng.seed)
	print("Generated map array") # TODO: Add prayer room and make rooms larger
	await spawn_rooms(Map.map_array, Map.map_size)
	print("Spawned rooms") # TODO: Fix rooms sometimes having lights out of bounds
	spawn_lights()
	print("Spawned lights")
	spawn_crates()
	print("Spawned crates")
	spawn_gems()
	print("Spawned gems") # TODO: Add gems
	spawn_loot()
	print("Spawned loot") # TODO: Add loot
	resize_floor(Map.map_size)
	print("Resized floor")
	await remove_hall_nodes()
	print("Removed hall nodes")


# Spawn the physical rooms in from the 2d array map
func spawn_rooms(map_array, map_size):
	const Hall = preload("res://src/scenes/hall.tscn")
	const R1 = preload("res://src/scenes/r1.tscn")
	const R2c = preload("res://src/scenes/r2c.tscn")
	const R2s = preload("res://src/scenes/r2s.tscn")
	const R3 = preload("res://src/scenes/r3.tscn")
	const R4 = preload("res://src/scenes/r4.tscn")
	
	# Loops through each index of map_array
	for y in map_size+2:
		for x in map_size+2:
			var instance # Every index gets a new temp instance variable
			var pattern # A tilemap pattern from an index number
			# If a tile is an elevator
			if map_array[x][y] == "E":
				Elevator.position.x = (y * room_spacing) + room_spacing/2
				Elevator.position.y = (x * room_spacing) + room_spacing/2
				Player.position = Elevator.position
			# If it has 0 connections
			elif map_array[x][y].match("?0"):
				pattern = LevelTileMap.tile_set.get_pattern(RoomPatterns.EMPTY)
			# If a tile is a hall
			elif map_array[x][y].match("H*"):
				instance = Hall.instantiate()
				instance.add_to_group("halls")
				# Spawns specific to each hall type
				if map_array[x][y].match("H1?"):
					instance.find_child("H1Spawns1").disabled = false
				elif map_array[x][y].match("H2?"):
					instance.find_child("H2sSpawns1").disabled = false
				elif map_array[x][y].match("H2??"):
					if rng.randf() > 0.50:
						instance.find_child("H2cSpawns1").disabled = false
					else:
						instance.find_child("H2cSpawns2").disabled = false
				elif map_array[x][y].match("H3?"):
					if rng.randf() > 0.50:
						instance.find_child("H3Spawns1").disabled = false
					else:
						instance.find_child("H3Spawns2").disabled = false
				elif map_array[x][y].match("H4"):
					if rng.randf() > 0.66:
						instance.find_child("H4Spawns1").disabled = false
					elif rng.randf() > 0.33:
						instance.find_child("H4Spawns2").disabled = false
					else:
						instance.find_child("H4Spawns3").disabled = false
				# Find pattern
				for n in RoomPatterns.size():
					if map_array[x][y] == RoomPatterns.keys()[n]:
						pattern = LevelTileMap.tile_set.get_pattern(n)
			# If a tile is a room
			elif map_array[x][y].match("R*"):
				# Instantiate
				if map_array[x][y].match("R1?"):
					instance = R1.instantiate()
				elif map_array[x][y].match("R2?"):
					instance = R2s.instantiate()
				elif map_array[x][y].match("R2??"):
					instance = R2c.instantiate()
				elif map_array[x][y].match("R3?"):
					instance = R3.instantiate()
				elif map_array[x][y].match("R4"):
					instance = R4.instantiate()
				# Remove tilemap used in the editor
				instance.find_child("TileMap").queue_free()
				# Find pattern
				for n in RoomPatterns.size():
					if map_array[x][y] == RoomPatterns.keys()[n]:
						pattern = LevelTileMap.tile_set.get_pattern(n)
			# If a tile is empty, the border, or invalid
			else:
				pattern = LevelTileMap.tile_set.get_pattern(RoomPatterns.EMPTY)
			# Rotate 1 and 3 connections
			if map_array[x][y].match("??E"):
				instance.rotate(PI/2)
			elif map_array[x][y].match("??S"):
				instance.rotate(PI)
			elif map_array[x][y].match("??W"):
				instance.rotate(-PI/2)
			# Rotate 2 connections
			elif map_array[x][y].match("?2H"):
				instance.rotate(PI/2)
			elif map_array[x][y].match("?2SE"):
				instance.rotate(PI/2)
			elif map_array[x][y].match("?2SW"):
				instance.rotate(PI)
			elif map_array[x][y].match("?2NW"):
				instance.rotate(-PI/2)
			# If the index's instance was initialized
			if instance != null:
				instance.position.x = (y * room_spacing) + room_spacing/2
				instance.position.y = (x * room_spacing) + room_spacing/2
				add_child(instance)
				add_nodes_to_groups(instance)
				
			# If a tilemap pattern has been set
			if pattern != null:
				var pattern_position = Vector2(y * room_tile_length, x * room_tile_length)
				LevelTileMap.set_pattern(0, pattern_position, pattern)


func add_nodes_to_groups(instance):
	# Enemy spawns
	for n in instance.find_children("EnemySpawn*"):
		n.add_to_group("enemy_spawns")
	# Light spawns
	for n in instance.find_children("HallLightSpawn?"):
		n.add_to_group("hall_light_spawns")
	for n in instance.find_children("RoomLightSpawn?"):
		n.add_to_group("room_light_spawns")
	# Generic hall spawns for specific hall types
	for n in instance.find_children("H?Spawns?"):
		if n.disabled == false:
			n.add_to_group("hall_spawns")


func spawn_lights():
	# Spawn lights
	for n in get_tree().get_nodes_in_group("hall_light_spawns"):
		if LevelParameters.hall_light_chance > rng.randf():
			instance_lights(n)
	for n in get_tree().get_nodes_in_group("room_light_spawns"):
		if LevelParameters.room_light_chance > rng.randf():
			instance_lights(n)
	# Remove light spawn nodes
	for n in get_tree().get_nodes_in_group("hall_light_spawns"):
		n.free()
	for n in get_tree().get_nodes_in_group("room_light_spawns"):
		n.free()


func instance_lights(n):
	const Light = preload("res://src/scenes/light.tscn")
	var instance = Light.instantiate()
	var spawn_min = n.global_position - n.shape.extents
	var spawn_max = n.global_position + n.shape.extents
	instance.position.x = rng.randi_range(spawn_min.x, spawn_max.x)
	instance.position.y = rng.randi_range(spawn_min.y, spawn_max.y)
	add_child(instance)
	instance.find_child("PointLight2D").add_to_group("lights")
	instance.find_child("GPUParticles2D").add_to_group("light_particles")
	instance.find_child("AudioStreamPlayer2D").add_to_group("light_sounds")


func spawn_crates():
	const Crate = preload("res://src/scenes/crate.tscn")
	for n in get_tree().get_nodes_in_group("hall_spawns"):
		if LevelParameters.crate_chance > rng.randf():
			var instance = Crate.instantiate()
			var spawn_min = n.global_position - n.shape.extents
			var spawn_max = n.global_position + n.shape.extents
			instance.position.x = rng.randi_range(spawn_min.x, spawn_max.x)
			instance.position.y = rng.randi_range(spawn_min.y, spawn_max.y)
			var size_multiplier = rng.randf_range(1, 1.9)
			instance.mass = 5 * size_multiplier
			for m in instance.get_children():
				m.scale.x = size_multiplier
				m.scale.y = size_multiplier
			instance.rotation = rng.randf_range(0, 45)
			add_child(instance)


func spawn_gems():
	pass


func spawn_loot():
	pass


func resize_floor(map_size):
	var size = room_spacing * (map_size+2)
	LevelFloor.size = Vector2(size, size)
	LevelFloor.get_child(0).size = Vector2(size, size)


func remove_hall_nodes():
	for n in get_tree().get_nodes_in_group("halls"):
		n.free()
