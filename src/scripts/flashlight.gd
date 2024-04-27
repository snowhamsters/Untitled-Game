extends PointLight2D
## Flashlight

var charge := 100.0			# Charge of a flashlight
var charge_life := 90.0		# Seconds the flashlight lasts
var brightness := 1.25		# Brightness multiplier of the flashlight
# Variables for energy noise
var noise_value := 0.0
const MAX_NOISE_VALUE := 1000000
@onready var noise := FastNoiseLite.new()


func _ready():
	noise_value = randi() % MAX_NOISE_VALUE


func _process(delta): # TODO: Show flashlight charge on HUD
	# User input to turn on and off the flashlight
	if Input.is_action_just_pressed("input_flashLight"):
		enabled = not enabled
	# Increment noiseValue 
	noise_value += delta * 75
	if noise_value > MAX_NOISE_VALUE:
		noise_value = 0.0
	# Logic involving flashlight charge and energy
	if charge > 0 and enabled:
		charge -= (delta * 1/charge_life * 100)
		energy = (noise.get_noise_1d(noise_value)/2 + (pow(charge,0.15) - 1)) * brightness
	elif charge < 0:
		charge = 0
		energy = 0
	# Flicker
	if 0.0025 > randf():
		energy = 0.0
