extends Node
## Keeps track of general variables

static var level_number := 0
static var level_name := ""
static var money := 0
static var total_money := 0
static var time := 0.0


func reset_run_stats():
	level_number = 0
	level_name = ""
	money = 0
	total_money = 0
	time = 0.0


func _process(delta):
	time += delta
