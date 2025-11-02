extends CharacterBody3D



# ============================================================================
# EXPORTED VARIABLES - Configure these in the Inspector
# ============================================================================

@export_group("Target Settings")
## The group name to find the player/target node (e.g., "player")
@export var player_group: String = "player"

## Alternative: Direct node path to the player (overrides group if set)
@export var player_path: NodePath = NodePath("")

## Stop moving when this close to the target (in meters)
@export_range(0.5, 10.0, 0.1) var stop_distance: float = 2.0

@export_group("Movement Settings")
## Maximum movement speed (meters per second)
@export_range(1.0, 20.0, 0.5) var movement_speed: float = 5.0

## How quickly the agent accelerates to max speed
@export_range(1.0, 50.0, 1.0) var acceleration: float = 10.0

## How quickly the agent rotates to face movement direction (radians per second)
@export_range(0.5, 20.0, 0.5) var rotation_speed: float = 8.0

@export_group("Navigation Settings")
## How often to recalculate the path (in seconds, 0 = every frame)
@export_range(0.0, 1.0, 0.05) var path_update_interval: float = 0.1

## Distance to consider a waypoint reached (should be small)
@export_range(0.1, 2.0, 0.1) var waypoint_tolerance: float = 0.5

@export_group("Animation Settings")
## Reference to the AnimatedSprite3D node (will auto-detect if left empty)
@export var sprite_path: NodePath = NodePath("")

## Minimum velocity to trigger movement animations (prevents jitter)
@export_range(0.1, 2.0, 0.1) var animation_velocity_threshold: float = 0.3

## Use camera/player position for determining sprite direction (DOOM-style)
@export var use_camera_relative_animations: bool = true

## Reference to camera (will use target/player position if not set)
@export var camera_path: NodePath = NodePath("")

## Angular buffer zone for each direction in degrees (larger = easier transitions)
@export_range(15.0, 75.0, 5.0) var direction_buffer_angle: float = 45.0

## Hysteresis to prevent rapid animation switching (degrees)
@export_range(0.0, 30.0, 5.0) var animation_switch_hysteresis: float = 10.0

@export_group("Debug Settings")
## Print debug information to console
@export var debug_mode: bool = false

## Show visual direction indicator
@export var show_direction_debug: bool = false

# ============================================================================
# INTERNAL VARIABLES
# ============================================================================

# Reference to the NavigationAgent3D child node
var nav_agent: NavigationAgent3D

# Reference to the target node being followed
var target_node: Node3D

# Reference to the AnimatedSprite3D node
var animated_sprite: AnimatedSprite3D

# Reference to the camera (for camera-relative animations)
var camera_node: Camera3D

# Timer for path recalculation
var path_update_timer: float = 0.0

# Flag to track if navigation is ready
var is_navigation_ready: bool = false

# Current animation state
var current_animation: String = "idle"

# Track last relative angle for hysteresis
var last_relative_angle: float = 0.0

# Previous velocity for smoothing
var previous_velocity: Vector3 = Vector3.ZERO

# Animation names
const ANIM_IDLE = "idle"
const ANIM_WALK_FORWARD = "walk_forward"
const ANIM_WALK_BACKWARD = "walk_backward"
const ANIM_WALK_LEFT = "walk_left"
const ANIM_WALK_RIGHT = "walk_right"

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Find the NavigationAgent3D child node
	nav_agent = get_node_or_null("navagent")
	
	if nav_agent == null:
		push_error("NavigationAgent3D child node not found! Please add one as a child of this node.")
		set_physics_process(false)
		return
	
	# Configure NavigationAgent3D properties
	nav_agent.path_desired_distance = waypoint_tolerance
	nav_agent.target_desired_distance = stop_distance
	nav_agent.max_speed = movement_speed
	
	# Find the AnimatedSprite3D node
	_find_animated_sprite()
	
	if animated_sprite == null:
		push_warning("AnimatedSprite3D not found. Animation system disabled.")
	else:
		_validate_animations()
	
	# Find the camera for camera-relative animations
	if use_camera_relative_animations:
		_find_camera()
	
	# Find the target node (player)
	_find_target_node()
	
	if target_node == null:
		if debug_mode:
			push_warning("Target node not found. Agent will remain stationary.")
		set_physics_process(false)
		return
	
	# Wait for navigation map to be ready
	call_deferred("_setup_navigation")

func _setup_navigation() -> void:
	# Wait for navigation map synchronization
	await get_tree().physics_frame
	is_navigation_ready = true
	
	if debug_mode:
		print("Navigation ready for: ", name)

# ============================================================================
# SPRITE AND ANIMATION DETECTION
# ============================================================================

func _find_animated_sprite() -> void:
	# First priority: Check if direct sprite path is set
	if sprite_path != NodePath(""):
		animated_sprite = get_node_or_null(sprite_path)
		if animated_sprite and debug_mode:
			print("AnimatedSprite3D found via node path: ", animated_sprite.name)
		return
	
	# Second priority: Search children for AnimatedSprite3D
	for child in get_children():
		if child is AnimatedSprite3D:
			animated_sprite = child
			if debug_mode:
				print("AnimatedSprite3D auto-detected: ", child.name)
			return
	
	push_warning("No AnimatedSprite3D found as child of ", name)

func _validate_animations() -> void:
	if animated_sprite == null:
		return
	
	var sprite_frames = animated_sprite.sprite_frames
	if sprite_frames == null:
		push_warning("AnimatedSprite3D has no SpriteFrames resource!")
		return
	
	# Check for required animations
	var required_anims = [ANIM_IDLE, ANIM_WALK_FORWARD, ANIM_WALK_BACKWARD, 
						  ANIM_WALK_LEFT, ANIM_WALK_RIGHT]
	var missing_anims = []
	
	for anim_name in required_anims:
		if not sprite_frames.has_animation(anim_name):
			missing_anims.append(anim_name)
	
	if missing_anims.size() > 0:
		push_warning("Missing animations in AnimatedSprite3D: ", missing_anims)
		if debug_mode:
			print("Available animations: ", sprite_frames.get_animation_names())

func _find_camera() -> void:
	# First priority: Check if direct camera path is set
	if camera_path != NodePath(""):
		camera_node = get_node_or_null(camera_path)
		if camera_node and debug_mode:
			print("Camera found via node path: ", camera_node.name)
		return
	
	# Second priority: Use viewport's camera
	var viewport = get_viewport()
	if viewport:
		camera_node = viewport.get_camera_3d()
		if camera_node and debug_mode:
			print("Camera auto-detected from viewport: ", camera_node.name)
		return
	
	if debug_mode:
		push_warning("No camera found for camera-relative animations. Will use player position instead.")

# ============================================================================
# TARGET DETECTION
# ============================================================================

func _find_target_node() -> void:
	# First priority: Check if direct node path is set
	if player_path != NodePath(""):
		target_node = get_node_or_null(player_path)
		if target_node and debug_mode:
			print("Target found via node path: ", target_node.name)
		return
	
	# Second priority: Find by group
	if player_group != "":
		var targets = get_tree().get_nodes_in_group(player_group)
		if targets.size() > 0:
			target_node = targets[0]
			if debug_mode:
				print("Target found via group '", player_group, "': ", target_node.name)
		else:
			push_warning("No nodes found in group '", player_group, "'")

# ============================================================================
# PHYSICS PROCESS - Main Update Loop
# ============================================================================

func _physics_process(delta: float) -> void:
	# Safety checks
	if not is_navigation_ready or target_node == null or nav_agent == null:
		return
	
	# Update path periodically or every frame
	path_update_timer += delta
	if path_update_timer >= path_update_interval:
		_update_navigation_target()
		path_update_timer = 0.0
	
	# Check if we've reached the target
	if nav_agent.is_navigation_finished():
		_update_animation(Vector3.ZERO)
		if debug_mode:
			print(name, " reached target position")
		return
	
	# Get the next position to move toward
	var next_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_position)
	
	# Calculate movement
	_move_toward_target(direction, delta)
	
	# Rotate to face movement direction
	_rotate_toward_direction(direction, delta)
	
	# Update sprite animation based on movement
	_update_animation(velocity)
	
	# Store velocity for next frame
	previous_velocity = velocity

# ============================================================================
# NAVIGATION LOGIC
# ============================================================================

func _update_navigation_target() -> void:
	# Check if target still exists
	if not is_instance_valid(target_node):
		if debug_mode:
			push_warning("Target node is no longer valid")
		set_physics_process(false)
		return
	
	# Set the target position for the navigation agent
	nav_agent.target_position = target_node.global_position
	
	if debug_mode:
		var distance = global_position.distance_to(target_node.global_position)
		print(name, " distance to target: ", snapped(distance, 0.1))

# ============================================================================
# MOVEMENT LOGIC
# ============================================================================

func _move_toward_target(direction: Vector3, delta: float) -> void:
	# Calculate desired velocity
	var desired_velocity = direction * movement_speed
	
	# Smoothly accelerate toward desired velocity
	velocity = velocity.lerp(desired_velocity, acceleration * delta)
	
	# Apply movement using CharacterBody3D's built-in method
	move_and_slide()

func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	# Don't rotate if not moving
	if direction.length() < 0.01:
		return
	
	# Calculate target rotation (only Y-axis for horizontal rotation)
	var target_rotation = atan2(direction.x, direction.z)
	var current_rotation = rotation.y
	
	# Smoothly interpolate to target rotation
	rotation.y = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)

# ============================================================================
# ANIMATION LOGIC - DOOM-Style Directional Sprites
# ============================================================================

func _update_animation(current_velocity: Vector3) -> void:
	if animated_sprite == null:
		return
	
	# Check if moving based on velocity threshold
	var speed = current_velocity.length()
	
	if speed < animation_velocity_threshold:
		_play_animation(ANIM_IDLE)
		return
	
	# Get the viewing position (camera or player)
	var viewer_position = _get_viewer_position()
	
	if viewer_position == Vector3.ZERO:
		# Fallback to simple world-space animation if no viewer found
		var movement_direction = current_velocity.normalized()
		var new_animation = _get_animation_for_direction(movement_direction)
		_play_animation(new_animation)
		return
	
	# Calculate direction from viewer to NPC (viewing angle)
	var view_direction = global_position - viewer_position
	view_direction.y = 0  # Flatten to horizontal plane
	view_direction = view_direction.normalized()
	
	# Calculate movement direction
	var movement_direction = current_velocity.normalized()
	movement_direction.y = 0  # Flatten to horizontal plane
	movement_direction = movement_direction.normalized()
	
	# Determine relative movement from viewer's perspective
	var relative_direction = _get_relative_direction_from_viewer(view_direction, movement_direction)
	
	# Select appropriate animation based on relative direction
	var new_animation = _get_animation_for_direction(relative_direction)
	_play_animation(new_animation)
	
	if debug_mode and show_direction_debug:
		print(name, " viewer angle, movement -> ", new_animation)

func _get_viewer_position() -> Vector3:
	# Use camera position if available and enabled
	if use_camera_relative_animations and camera_node != null:
		return camera_node.global_position
	
	# Fallback to target/player position
	if target_node != null:
		return target_node.global_position
	
	# No viewer found
	return Vector3.ZERO

func _get_relative_direction_from_viewer(view_dir: Vector3, move_dir: Vector3) -> Vector3:
	# Calculate the angle between viewer's direction to NPC and movement direction
	# This determines if NPC is moving toward/away/left/right relative to viewer
	
	# Get the angle of viewer looking at NPC (in XZ plane)
	var view_angle = atan2(view_dir.x, view_dir.z)
	
	# Get the angle of NPC's movement
	var move_angle = atan2(move_dir.x, move_dir.z)
	
	# Calculate relative angle (movement relative to viewing angle)
	var relative_angle = move_angle - view_angle
	
	# Normalize angle to -PI to PI range
	while relative_angle > PI:
		relative_angle -= TAU
	while relative_angle < -PI:
		relative_angle += TAU
	
	# Apply hysteresis if we have a previous angle
	# This prevents rapid switching between animations at boundary angles
	if current_animation != ANIM_IDLE:
		var angle_diff = abs(relative_angle - last_relative_angle)
		var hysteresis_rad = deg_to_rad(animation_switch_hysteresis)
		
		# If the angle hasn't changed much, keep using the last angle
		if angle_diff < hysteresis_rad:
			relative_angle = last_relative_angle
	
	# Store for next frame
	last_relative_angle = relative_angle
	
	# Convert angle to direction vector for animation selection with buffer zones
	# Using buffer zones means each direction covers a wider angular range
	
	var buffer_rad = deg_to_rad(direction_buffer_angle)
	
	# Define angular ranges for each direction with overlapping buffer zones:
	# Forward (away from viewer): 180° ± buffer
	# Backward (toward viewer): 0° ± buffer  
	# Right: 90° ± buffer
	# Left: -90° ± buffer
	
	var angle_deg = rad_to_deg(relative_angle)
	
	if debug_mode and show_direction_debug:
		print(name, " relative angle: ", snapped(angle_deg, 0.1), "°")
	
	# Check each direction with buffer zone
	# Forward: moving away from viewer (around 180°)
	if abs(relative_angle - PI) < buffer_rad or abs(relative_angle + PI) < buffer_rad:
		return Vector3(0, 0, 1)  # Forward
	
	# Backward: moving toward viewer (around 0°)
	if abs(relative_angle) < buffer_rad:
		return Vector3(0, 0, -1)  # Backward
	
	# Right: moving to viewer's right (around 90°)
	if abs(relative_angle - PI/2) < buffer_rad:
		return Vector3(1, 0, 0)  # Right
	
	# Left: moving to viewer's left (around -90°)
	if abs(relative_angle + PI/2) < buffer_rad:
		return Vector3(-1, 0, 0)  # Left
	
	# Fallback: determine by quadrant for edge cases
	var abs_angle = abs(angle_deg)
	
	if abs_angle > 135:  # Closer to 180° (forward)
		return Vector3(0, 0, 1)
	elif abs_angle < 45:  # Closer to 0° (backward)
		return Vector3(0, 0, -1)
	elif angle_deg > 0:  # Positive angle (right)
		return Vector3(1, 0, 0)
	else:  # Negative angle (left)
		return Vector3(-1, 0, 0)

func _get_relative_movement_direction(move_velocity: Vector3) -> Vector3:
	# This function is now deprecated in favor of camera-relative calculations
	# Kept for backward compatibility
	var direction = move_velocity.normalized()
	var local_direction = direction.rotated(Vector3.UP, -rotation.y)
	return local_direction

func _get_animation_for_direction(direction: Vector3) -> String:
	# Determine which animation to play based on the direction vector
	# Direction vector has already been processed with buffer zones
	
	var abs_x = abs(direction.x)
	var abs_z = abs(direction.z)
	
	# The direction vector from _get_relative_direction_from_viewer is already
	# simplified to cardinal directions, so we can directly check components
	
	if abs_z > abs_x:
		# Moving primarily along Z axis
		if direction.z > 0:
			return ANIM_WALK_FORWARD   # Moving away from viewer
		else:
			return ANIM_WALK_BACKWARD  # Moving toward viewer
	else:
		# Moving primarily along X axis
		if direction.x > 0:
			return ANIM_WALK_RIGHT     # Moving to viewer's right
		else:
			return ANIM_WALK_LEFT      # Moving to viewer's left

func _play_animation(animation_name: String) -> void:
	# Only change animation if different from current
	if current_animation == animation_name:
		return
	
	# Verify animation exists
	if animated_sprite.sprite_frames and not animated_sprite.sprite_frames.has_animation(animation_name):
		if debug_mode:
			push_warning("Animation '", animation_name, "' not found in sprite frames")
		return
	
	# Play the new animation
	animated_sprite.play(animation_name)
	current_animation = animation_name
	
	if debug_mode:
		print(name, " switched to animation: ", animation_name)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================


## Call this to change the target at runtime
func set_target(new_target: Node3D) -> void:
	target_node = new_target
	if not is_physics_processing():
		set_physics_process(true)
	
	if debug_mode:
		print(name, " target changed to: ", new_target.name if new_target else "null")

## Get the current distance to target
func get_distance_to_target() -> float:
	if target_node == null:
		return -1.0
	return global_position.distance_to(target_node.global_position)

## Check if the agent has reached the target
func has_reached_target() -> bool:
	if nav_agent == null:
		return false
	return nav_agent.is_navigation_finished()

## Manually trigger path recalculation
func recalculate_path() -> void:
	if is_navigation_ready and target_node != null:
		_update_navigation_target()

## Force play a specific animation (for events, death, etc.)
func force_animation(animation_name: String) -> void:
	if animated_sprite == null:
		return
	
	current_animation = animation_name
	animated_sprite.play(animation_name)

## Get the current animation name
func get_current_animation() -> String:
	return current_animation
