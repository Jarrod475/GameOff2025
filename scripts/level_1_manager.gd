extends CanvasLayer

@onready var spawn_point_parent = $ColorRect/SubViewport/Environment/enemy_spawns
@onready var env = $ColorRect/SubViewport/Environment
@onready var enemy = preload("res://scenes/enemy_2.tscn")

@onready var spawn_timer = $spawn_timer
var spawn_pipe_index = 1

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	var new_enemy = enemy.instantiate()
	spawn_pipe_index += 1
	if spawn_pipe_index > 3:
		spawn_pipe_index = 1
	match spawn_pipe_index:
		1: new_enemy.position =  $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_2.global_position
		2: new_enemy.position = $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_3.global_position
		3: new_enemy.position = $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_4.global_position
	env.add_child(new_enemy)
