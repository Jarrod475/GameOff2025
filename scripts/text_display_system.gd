extends Label

var running = false
var current_speed = 1.0
var current_timeout = 5.0


##call this function to display text on the hud.
##timeout is the time it will wait until hiding the text box
##speed changes how quickly the text is displayed
func display_text(text_to_display : String, speed = 2.5,timeout = 5):
	current_timeout = timeout
	current_speed = speed
	visible_ratio = 0
	text = text_to_display
	running = true
	visible = true
	
func _process(delta: float) -> void:
	if !running and current_timeout > 0:
		current_timeout-= delta
		if current_timeout <= 0:
			current_timeout = 0
			visible = false
			return
	elif !running:
		return
	else:
		visible_ratio += delta * current_speed
		if visible_ratio >= 1:
			running = false
