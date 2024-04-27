extends Node2D
## Loads a level and handles overall level logic

signal level_ready()
@onready var LevelGeneration: Node2D = %LevelGeneration
@onready var LoadingScreen: CanvasLayer = %LoadingScreen


func _ready():
	# TODO: Fix loading screen
	# TODO: Add the pickaxe + destructable terrain
	LoadingScreen.visible = true
	var time = Time.get_ticks_msec()
	# Waiting for level generation
	await LevelGeneration.generate_level("Abyss", "none")
	# The level is now generated and loaded
	print(Time.get_ticks_msec()-time)
	level_ready.emit()
	LoadingScreen.visible = false
