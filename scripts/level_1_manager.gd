extends CanvasLayer

@onready var spawn_point_parent = $ColorRect/SubViewport/Environment/enemy_spawns
@onready var env = $ColorRect/SubViewport/Environment
@onready var enemy = preload("res://scenes/enemy_2.tscn")

@onready var shader_controller = $ColorRect
@onready var text_controller = $ColorRect/SubViewport/HUD/text_display_bottom

@onready var spawn_timer = $spawn_timer
var spawn_pipe_index = 1

var terminal_1_active = false
var terminal_2_active = false

var enemy_list = []
var enemy_limit = 20

@export var debug = false

func _ready() -> void:
	$ColorRect/SubViewport/Environment/terminal.terminal_activated.connect(terminal_activated)
	$ColorRect/SubViewport/Environment/terminal2.terminal_activated.connect(terminal_activated)
	if debug:
		spawn_timer.start()
		return
	
	await get_tree().create_timer(1).timeout
	text_controller.display_text("Wow a lockdown? Never had one of those...")
	await get_tree().create_timer(5).timeout
	text_controller.display_text("One of those clankers Must've escaped.")
	await get_tree().create_timer(5).timeout
	text_controller.display_text("Guess this is a job for ole Jimmy!")
	
func _on_spawn_timer_timeout() -> void:
	if enemy_list.size() > enemy_limit:
		spawn_timer.stop()
	var new_enemy = enemy.instantiate()
	spawn_pipe_index += 1
	if spawn_pipe_index > 3:
		spawn_pipe_index = 1
	match spawn_pipe_index:
		1: new_enemy.position =  $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_2.global_position
		2: new_enemy.position = $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_3.global_position
		3: new_enemy.position = $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_4.global_position
	env.add_child(new_enemy)
	enemy_list.append(new_enemy)

func terminal_activated():
	if terminal_1_active:
		terminal_2_active = true
		spawn_timer.start()
	else:
		terminal_1_active = true
