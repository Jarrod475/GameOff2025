extends CanvasLayer

@onready var spawn_point_parent = $ColorRect/SubViewport/Environment/enemy_spawns
@onready var env = $ColorRect/SubViewport/Environment
@onready var enemy = preload("res://scenes/enemy_2.tscn")

@onready var shader_controller = $ColorRect
@onready var text_controller = $ColorRect/SubViewport/HUD/text_display_bottom

@onready var terminal_1  = $ColorRect/SubViewport/Environment/terminal
@onready var terminal_2 = $ColorRect/SubViewport/Environment/terminal2

@onready var spawn_timer = $spawn_timer

@onready var door_1 = $ColorRect/SubViewport/Environment/door
@onready var door_2 = $ColorRect/SubViewport/Environment/door3

var spawn_pipe_index = 1

var terminal_1_active = false
var terminal_2_active = false

var enemy_list = []
var enemy_limit = 1
var spawn_limit_reached = false
var enemy_counter = 0

@export var debug = false

var round_counter = 1

func _ready() -> void:
	terminal_1.terminal_activated.connect(terminal_activated)
	terminal_2.terminal_activated.connect(terminal_activated)
	if debug:
		spawn_timer.start()
		return
	
	await get_tree().create_timer(1).timeout
	text_controller.display_text("Wow a lockdown? Never had one of those...")
	await get_tree().create_timer(5).timeout
	text_controller.display_text("One of those clankers Must've escaped.")
	await get_tree().create_timer(5).timeout
	text_controller.display_text("Guess this is a job for ole Jimmy!")

func _process(_delta: float) -> void:
	if spawn_limit_reached and enemy_list.is_empty():
		spawn_limit_reached = false
		next_round()

func _on_spawn_timer_timeout() -> void:
	if enemy_counter >= enemy_limit:
		spawn_timer.stop()
		spawn_limit_reached = true
	enemy_counter += 1
	var new_enemy = enemy.instantiate()
	spawn_pipe_index += 1
	if spawn_pipe_index > 3:
		spawn_pipe_index = 1
	match spawn_pipe_index:
		1: new_enemy.position =  $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_2.global_position
		2: new_enemy.position = $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_3.global_position
		3: new_enemy.position = $ColorRect/SubViewport/Environment/enemy_spawns/spawn_point_4.global_position
	env.add_child(new_enemy)
	new_enemy.died.connect(remove_enemy)
	enemy_list.append(new_enemy)

func terminal_activated():
	if terminal_1_active:
		terminal_2_active = true
		spawn_timer.start()
		door_1.lock()
	else:
		terminal_1_active = true

func next_round():
	round_counter += 1
	if round_counter == 2:
		await  get_tree().create_timer(1).timeout
		text_controller.display_text("Need to reset the ventilation system to get passed!")
	if round_counter == 3:
		await  get_tree().create_timer(1).timeout
		text_controller.display_text("One more and the system should be flushed of them varmints!")
	if round_counter == 4:
		text_controller.display_text("Easy Peazy! I should probably find myself a bigger gun...")
		door_2.unlock()
		return
	enemy_counter = 0
	spawn_limit_reached = false
	enemy_list.clear()
	enemy_limit += 10
	terminal_1_active = false
	terminal_2_active = false
	terminal_1.reset_terminal()
	terminal_2.reset_terminal()

func remove_enemy(enemy_to_remove):
	enemy_list.erase(enemy_to_remove)
