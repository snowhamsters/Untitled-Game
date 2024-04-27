extends PointLight2D
## Simulates random light energy using noise

var noise_speed := 15
var base_energy := 0.4
var energy_multiplier := 0.33
var base_scale := 1.0
var scale_multiplier := 0.1
var noise_value := 0.0
const MAX_NOISE_VALUE := 1000000
@onready var noise := FastNoiseLite.new()


func _ready():
	noise_value = randi() % MAX_NOISE_VALUE


func _process(delta):
	# Increment noiseValue 
	noise_value += delta * noise_speed
	if noise_value > MAX_NOISE_VALUE:
		noise_value = 0.0
	# Energy and size
	energy = base_energy + (noise.get_noise_1d(noise_value) * energy_multiplier)
	texture_scale = base_scale + (noise.get_noise_1d(noise_value) * scale_multiplier)
	# Flicker
	if 0.0025 > randf():
		energy = 0.0
