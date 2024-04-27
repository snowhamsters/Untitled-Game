extends Node2D
## Elevator

var is_level_ready := false

#@onready var Level: Node2D = get_tree().root.get_node("Level")
@onready var LevelLights: Node2D = %LevelLights
@onready var LightTimer: Timer = LevelLights.get_node("LightTimer")


#func _ready():
	#Level.level_ready.connect(level_ready)
#
#
## Wait for the level to be loaded before accessing nodes
#func level_ready():
	#is_level_ready = true


func _process(_delta):
	$ProgressBar.value = (LightTimer.time_left / LevelParameters.light_time) * 100
