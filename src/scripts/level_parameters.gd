class_name LevelParameters
extends Node
## A list of level parameters

static var map_size: int				# Size of the map
static var batteries: int				# Number of batteries
static var safe_time: float				# Seconds until enemy spawns start
static var enemy_types: Array			# Chance array of each enemy being spawned
static var starting_enemies: int		# Number of starting enemies in a level
static var max_enemies: int				# Max number of enemies in a level
static var enemy_spawn_period: float	# Seconds between enemy spawns
static var enemy_spawn_chance: float	# Chance of a successful spawn
static var light_time: float			# Time until lights go out
static var hall_light_chance: float		# Chance a light will spawn in a hall
static var room_light_chance: float		# Chance a light will spawn in a room
static var crate_chance: float			# Chance for a crate to spawn
static var gem_chance: float			# Chance a gem will spawn
static var gem_quality: float			# Quality of gems
static var loot_chance: float			# Chance loot will spawn


static func set_level_parameters(level_name, modifier):
	batteries = 2
	safe_time = 30.00
	starting_enemies = 1
	max_enemies = 5
	enemy_spawn_period = 20.00
	enemy_spawn_chance = 0.50
	light_time = 90.00
	hall_light_chance = 0.30
	room_light_chance = 0.95
	crate_chance = 0.15
	gem_chance = 0.25
	gem_quality = 10
	loot_chance = 0.10
	
	if level_name == "A":
		map_size = 9
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "B":
		map_size = 11
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "C":
		map_size = 13
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "D":
		map_size = 13
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "E":
		map_size = 15
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "F":
		map_size = 15
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "G":
		map_size = 17
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "H":
		map_size = 17
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "I":
		map_size = 19
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "J":
		map_size = 19
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "Nadir":
		map_size = 21
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	elif level_name == "Abyss":
		map_size = 21
		enemy_types = [0,0,0,0,0,0,0,0,0,0]
	
	if modifier == "blackout":
		batteries += 1
		safe_time = 5.0
		light_time = 1.00
