extends Node2D
## Logic for enemies in the level

var number_of_enemies := 0
var enemy_retries := 0
@onready var Level: Node2D = get_tree().root.get_node("Level")
@onready var Player: CharacterBody2D = %Player
@onready var SafeTimer: Timer = get_node("SafeTimer")
@onready var EnemySpawnTimer: Timer = get_node("EnemySpawnTimer")


func _ready():
	Level.level_ready.connect(level_ready) # Wait for the level to be generated


func level_ready():
	for i in LevelParameters.starting_enemies:
		spawn_enemy()
	SafeTimer.wait_time = LevelParameters.safe_time
	SafeTimer.start()


func spawn_enemy():
	var enemy_spawns: Array = get_tree().get_nodes_in_group("enemy_spawns")
	var enemyPosition = enemy_spawns[randi_range(0, enemy_spawns.size()-1)].global_position
	
	if (number_of_enemies >= LevelParameters.max_enemies):
		EnemySpawnTimer.stop()
		EnemySpawnTimer.queue_free()
		return
	
	if ((enemyPosition.x - Player.position.x) < 200 and
			(enemyPosition.y - Player.position.y) < 200 and enemy_retries <= 5):
		print("invalid spawn... retrying")
		enemy_retries += 1
		spawn_enemy()
	else:
		if LevelParameters.enemy_spawn_chance > randf():
			print("Enemy spawned: ", enemyPosition)
		else:
			print("Failed spawn: ", enemyPosition)


func _on_safe_timer_timeout():
	EnemySpawnTimer.wait_time = LevelParameters.enemy_spawn_period
	EnemySpawnTimer.start()
	SafeTimer.stop()
	SafeTimer.queue_free()


func _on_enemy_spawn_timer_timeout():
	enemy_retries = 0
	spawn_enemy()
