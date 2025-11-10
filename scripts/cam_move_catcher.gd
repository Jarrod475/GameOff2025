extends Node3D

signal interact
signal pew

var can_pew = false

func _ready() -> void:
	# Capture mouse cursor for FPS controls
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$fire_timer.start(GunData.fire_rate)
	
	
func _input(event: InputEvent) -> void:
	# Handle mouse movement for camera rotation
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$"../ColorRect/SubViewport/Environment/Player".get_mouse_data(event)
	
	if event.is_action_pressed("interact"):
		interact.emit()
	if event.is_action_pressed("shoot") and can_pew:
		pew.emit()
		can_pew = false
		$fire_timer.start(GunData.fire_rate)
	
	


func _on_fire_timer_timeout() -> void:
	can_pew = true
