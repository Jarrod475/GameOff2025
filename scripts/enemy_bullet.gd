extends Node3D

@onready var area = $area
var player 
var direction
var time_alive = 0.0
var lifetime = 10.0
@export var speed = 5

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	direction = _calculate_direction_to_player()
	
func _process(delta: float) -> void:
	# Move bullet in direction
	global_position += direction * speed * delta
	
	# Update lifetime counter
	time_alive += delta
	
	# Destroy if lifetime exceeded
	if time_alive >= lifetime:
		queue_free()

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.die()
		queue_free()
	elif body.is_in_group("terrain"):
		queue_free()


## Calculates and normalizes direction vector from NPC to player in 3D space
func _calculate_direction_to_player() -> Vector3:
	# Calculate raw direction vector
	var _direction = player.global_position - global_position
	
	# Normalize for consistent bullet speed regardless of distance
	if _direction.length() > 0:
		_direction = _direction.normalized()
	else:
		push_warning("NPCShooter3D: Player is at same position as NPC. Cannot calculate direction.")
		return Vector3.ZERO
	
	return _direction
