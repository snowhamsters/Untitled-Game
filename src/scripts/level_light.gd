extends Node2D
## Ceiling light logic


var noise_speed := 15
var base_energy := 1.25
var energy_multiplier := 0.25
var base_scale := 1.5
var scale_multiplier := 0.25

var lights_on := true
var lights: Array
var light_particles: Array
var light_sounds: Array

var noise_value := 0.0
const MAX_NOISE_VALUE := 1000000
@onready var noise := FastNoiseLite.new()

@onready var Level: Node2D = get_tree().root.get_node("Level")
@onready var LightTimer: Timer = get_node("LightTimer")
@onready var EvilTimer: Timer = get_node("EvilTimer")
@onready var FreeLightsTimer: Timer = get_node("FreeLightsTimer")
@onready var BlackoutSound: AudioStreamPlayer = get_node("BlackoutSound")


func _ready():
	Level.level_ready.connect(level_ready) # Wait for the level to be generated
	noise_value = randi() % MAX_NOISE_VALUE


func level_ready():
	lights = get_tree().get_nodes_in_group("lights")
	light_particles = get_tree().get_nodes_in_group("light_particles")
	light_sounds = get_tree().get_nodes_in_group("light_sounds")
	LightTimer.start(LevelParameters.light_time)


func _process(delta):
	# Before blackout
	if lights_on == true:
		# Increment noiseValue 
		noise_value += delta * noise_speed
		if noise_value > MAX_NOISE_VALUE:
			noise_value = 0.0
		for n in lights:
			# Energy and size
			n.energy = base_energy + (noise.get_noise_1d(noise_value) * energy_multiplier)
			n.texture_scale = base_scale + (noise.get_noise_1d(noise_value) * scale_multiplier)
			# Flicker
			if 0.0025 > randf():
				n.energy = 0.0
	# After blackout
	else:
		for n in lights:
			n.energy -= delta * 3
			if n.energy <= 0:
				n.energy = 0


func _on_light_timer_timeout():
	# Turn off lights
	lights_on = false
	# Turn off particles
	for n in light_particles:
		n.emitting = false
	# Turn off light ambience
	for n in light_sounds:
		n.queue_free()
	# Play blackout sound
	BlackoutSound.play() # TODO: Add blackout sound
	# Start FreeLightsTimer
	FreeLightsTimer.start(5)
	# Start EvilTimer
	EvilTimer.start(30)


func _on_free_lights_timer_timeout():
	# Frees all light components except sprites
	for n in lights:
		n.queue_free()
	for n in light_particles:
		n.queue_free()
	# Turns this script off
	set_script(null)
