extends Node3D
@onready var bullet = load("res://scenes/enemy_bullet.tscn")
@onready var bullet_parent_node = $"../.."

var time_to_fire = 0
@export var fire_min = 2.0
@export var fire_max = 6.0
func _ready() -> void:
	time_to_fire = get_random_time()
	
func _process(delta: float) -> void:
	if time_to_fire <= 0:
		fire()
		time_to_fire = get_random_time()
	else:
		time_to_fire -= delta
	
	
func fire():
	var new_bullet = bullet.instantiate()
	new_bullet.global_position = global_position
	bullet_parent_node.add_child(new_bullet)

func get_random_time():
	return randf_range(fire_min,fire_max)
