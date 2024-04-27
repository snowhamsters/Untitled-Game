extends CanvasLayer
## The menu shown by pressing "input_esc"


# High latency, but only called on input events
func _input(_event):
	if Input.is_action_just_pressed("input_esc"):
		visible = not visible
		get_tree().paused = not get_tree().paused
