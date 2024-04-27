extends CharacterBody2D
## Player script

var speed := 300
var acceleration := 10
var friction := 100
var input := Vector2.ZERO
var push_force = 100.0

@onready var PushCrateSound: AudioStreamPlayer2D = get_node("PushCrateSound")


func _physics_process(delta):
	player_movement(delta)
	look_at(get_global_mouse_position())
	$Label.text = str(position.x).pad_decimals(0)
	$Label2.text = str(position.y).pad_decimals(0)


func player_movement(delta): # TODO: Add sprinting and crouching
	input = Input.get_vector('input_left', 'input_right', 'input_up', 'input_down')
	if input.length() > 0:
		velocity = velocity.move_toward(input * speed, acceleration * 1000 * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * 1000 * delta)
	move_and_slide()
	
	collision_logic()


func collision_logic():
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
			if PushCrateSound.playing == false and (snapped(c.get_travel().x, 0.25) != 0 or
					snapped(c.get_travel().y, 0.25) != 0):
				PushCrateSound.play()
