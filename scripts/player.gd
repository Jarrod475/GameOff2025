extends CharacterBody3D
## Classic Doom 2-Style First Person Character Controller
## 
## This script provides arcade-style FPS movement with instant acceleration,
## high speeds, and classic strafe-running mechanics inspired by Doom 2.
##
## Required Node Structure:
## CharacterBody3D (this script)
## └─ Camera3D (child node for first-person view)
##
## Controls:
## - WASD: Movement
## - Mouse: Look around
## - Space: Jump
## - Shift: Sprint (optional)

# ============================================================================
# MOVEMENT CONSTANTS
# ============================================================================

## Base movement speed in units per second (Doom-style is fast!)
@export_range(5.0, 20.0, 0.5) var base_speed: float = 12.0

## Sprint multiplier when holding shift
@export_range(1.0, 2.0, 0.1) var sprint_multiplier: float = 1.5

## Jump velocity (negative Y is up in Godot)
@export_range(3.0, 10.0, 0.5) var jump_velocity: float = 6.0

## Gravity multiplier (Doom had stronger gravity than realistic)
@export_range(1.0, 3.0, 0.1) var gravity_multiplier: float = 1.5

## Air control factor (1.0 = full control, 0.0 = no control)
## Classic Doom had full air control
@export_range(0.0, 1.0, 0.1) var air_control: float = 1.0

## Strafe running multiplier (diagonal movement boost)
## Set to 1.414 (sqrt(2)) for authentic Doom strafe-running
@export_range(1.0, 1.5, 0.01) var strafe_run_multiplier: float = 1.414

# ============================================================================
# MOUSE LOOK CONSTANTS
# ============================================================================

## Horizontal mouse sensitivity
@export_range(0.001, 0.01, 0.0001) var mouse_sensitivity: float = 0.003

## Vertical mouse sensitivity
@export_range(0.001, 0.01, 0.0001) var mouse_vertical_sensitivity: float = 0.003

## Maximum vertical look angle in degrees (prevents over-rotation)
@export_range(80.0, 90.0, 1.0) var max_look_angle: float = 89.0

## Enable head bobbing effect
@export var enable_head_bob: bool = true

## Head bob frequency (cycles per second)
@export_range(1.0, 5.0, 0.1) var bob_frequency: float = 2.5

## Head bob amplitude (movement distance)
@export_range(0.01, 0.2, 0.01) var bob_amplitude: float = 0.08

# ============================================================================
# INTERNAL VARIABLES
# ============================================================================

# Reference to the camera node
@onready var camera: Camera3D = $cam

# Current vertical rotation in radians
var camera_rotation: float = 0.0

# Head bob timer for sine wave calculation
var bob_timer: float = 0.0

# Initial camera Y position for head bob
var initial_camera_y: float = 0.0

# Get gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Capture mouse cursor for FPS controls
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Store initial camera position
	if camera:
		initial_camera_y = camera.position.y
	else:
		push_error("Camera3D node not found! Please add a Camera3D as a child of this CharacterBody3D")

# ============================================================================
# INPUT HANDLING
# ============================================================================


func get_mouse_data(event):
	_input(event)

func _input(event: InputEvent) -> void:
	# Handle mouse movement for camera rotation
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_look(event.relative)
	
	# Toggle mouse capture with Escape key (for debugging/menu)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ============================================================================
# PHYSICS PROCESSING
# ============================================================================

func _physics_process(delta: float) -> void:
	# Apply gravity when not on floor
	apply_gravity(delta)
	
	# Handle jump input
	handle_jump()
	
	# Get movement input and apply movement
	var input_dir := get_input_direction()
	handle_movement(input_dir, delta)
	
	# Apply head bob effect
	if enable_head_bob:
		apply_head_bob(delta, input_dir)
	
	# Move the character
	move_and_slide()

# ============================================================================
# MOVEMENT FUNCTIONS
# ============================================================================

## Applies gravity to the character's velocity
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

## Handles jump input and applies jump velocity
func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

## Gets normalized input direction from player input
func get_input_direction() -> Vector2:
	# Get input from WASD/Arrow keys
	var input_dir := Input.get_vector("left", "right", "backward", "forward")
	return input_dir

## Handles horizontal movement with Doom-style instant acceleration
func handle_movement(input_dir: Vector2, delta: float) -> void:
	# Determine current speed (with sprint if applicable)
	var current_speed := base_speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	# Calculate movement direction relative to where player is looking
	var direction := Vector3.ZERO
	if input_dir.length() > 0.0:
		# Get the character's forward and right vectors
		var forward := -global_transform.basis.z
		var right := global_transform.basis.x
		
		# Flatten to horizontal plane (ignore Y component)
		forward.y = 0.0
		forward = forward.normalized()
		right.y = 0.0
		right = right.normalized()
		
		# Combine forward and right movement
		direction = (forward * input_dir.y + right * input_dir.x).normalized()
		
		# Apply strafe-running multiplier for diagonal movement
		# This gives the classic Doom speedrun boost
		if abs(input_dir.x) > 0.1 and abs(input_dir.y) > 0.1:
			current_speed *= strafe_run_multiplier
	
	# Apply air control multiplier if not on ground
	var control_factor := 1.0
	if not is_on_floor():
		control_factor = air_control
	
	# Doom-style instant acceleration (no lerp/smoothing)
	# This creates the responsive, arcade-like feel
	velocity.x = direction.x * current_speed * control_factor
	velocity.z = direction.z * current_speed * control_factor

# ============================================================================
# CAMERA FUNCTIONS
# ============================================================================

## Handles mouse look for first-person camera control
func handle_mouse_look(mouse_delta: Vector2) -> void:
	if not camera:
		return
	
	# Rotate character body horizontally (yaw)
	rotate_y(-mouse_delta.x * mouse_sensitivity)
	
	# Rotate camera vertically (pitch) with clamping
	camera_rotation -= mouse_delta.y * mouse_vertical_sensitivity
	camera_rotation = clamp(camera_rotation, 
		deg_to_rad(-max_look_angle), 
		deg_to_rad(max_look_angle))
	
	# Apply rotation to camera
	camera.rotation.x = camera_rotation

## Applies classic FPS head bob effect when moving
func apply_head_bob(delta: float, input_dir: Vector2) -> void:
	if not camera:
		return
	
	# Only bob when moving on ground
	if is_on_floor() and input_dir.length() > 0.0:
		# Increment bob timer based on movement speed
		bob_timer += delta * bob_frequency
		
		# Calculate sine wave for smooth bobbing motion
		var bob_offset := sin(bob_timer * TAU) * bob_amplitude
		
		# Apply vertical offset
		camera.position.y = initial_camera_y + bob_offset
	else:
		# Gradually return to initial position when not moving
		bob_timer = 0.0
		camera.position.y = lerp(camera.position.y, initial_camera_y, delta * 10.0)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

## Returns current horizontal speed (useful for UI speedometers)
func get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()

## Returns whether player is sprinting
func is_sprinting() -> bool:
	return Input.is_action_pressed("sprint")

## Manually set mouse capture state (useful for menus)
func set_mouse_captured(captured: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE
