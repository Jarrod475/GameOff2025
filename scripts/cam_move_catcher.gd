extends Node3D

signal interact
signal pew

func _ready() -> void:
	# Capture mouse cursor for FPS controls
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _input(event: InputEvent) -> void:
	# Handle mouse movement for camera rotation
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$"../ColorRect/SubViewport/Environment/Player".get_mouse_data(event)
	
	if event.is_action_pressed("interact"):
		interact.emit()
	if event.is_action_pressed("shoot"):
		pew.emit()
	
	
