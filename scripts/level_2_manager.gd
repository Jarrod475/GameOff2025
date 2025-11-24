extends CanvasLayer

var spawn_point_parent 
@onready var env = $ColorRect/SubViewport/Environment
@onready var enemy_2 = preload("res://scenes/enemy_2.tscn")
@onready var enemy_1 = preload("res://scenes/enemy_1.tscn")

@onready var text_controller = $ColorRect/SubViewport/HUD/text_display_bottom


@onready var spawn_timer = $spawn_timer
var spawn_pipe_index = 1
var enemy_list = []
var enemy_limit = 1
var spawn_limit_reached = false
var enemy_counter = 0

##triggers
var warehouse_2_trigger = false
var cafe_trigger = false

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	text_controller.display_text("I need to find a way out of here...")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if warehouse_2_trigger and spawn_limit_reached and enemy_list.is_empty():
		spawn_limit_reached = false
		spawn_timer.stop()
		warehouse_2_finished()
	if cafe_trigger and spawn_limit_reached and enemy_list.is_empty():
		spawn_limit_reached = false
		spawn_timer.stop()
		cafe_finished()
		

func _on_warehouse_2_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		trigger_warehouse_2_fight()


func _on_cafe_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		trigger_cafe_fight()
	
	
	
func trigger_warehouse_2_fight():
	if warehouse_2_trigger:
		return
	$ColorRect/SubViewport/Environment/warehouse2_trigger.monitoring = false
	warehouse_2_trigger = true
	spawn_point_parent = $ColorRect/SubViewport/Environment/enemy_spawns_wh2
	var door_1 = $ColorRect/SubViewport/Environment/level_2/door12
	door_1.toggle_invisible_wall()
	door_1.lock()
	spawn_timer.start()


func trigger_cafe_fight():
	if cafe_trigger:
		return
	cafe_trigger = true
	$ColorRect/SubViewport/Environment/cafe_trigger.monitoring = false
	spawn_point_parent= $ColorRect/SubViewport/Environment/enemy_spawns_cafe
	var door_1 = $ColorRect/SubViewport/Environment/level_2/door10
	door_1.toggle_invisible_wall()
	door_1.lock()
	spawn_timer.start()

func warehouse_2_finished():
	$ColorRect/SubViewport/Environment/level_2/door11.unlock()
	$ColorRect/SubViewport/Environment/level_2/door12.unlock()
	$ColorRect/SubViewport/Environment/level_2/door12.toggle_invisible_wall()
	$ColorRect/SubViewport/Environment/level_2/door2.unlock()
	enemy_list.clear()
	

func cafe_finished():
	$ColorRect/SubViewport/Environment/level_2/door10.toggle_invisible_wall()
	$ColorRect/SubViewport/Environment/level_2/door10.unlock()
	print("CAFE DONEZO")
	##continue here


func _on_spawn_timer_timeout() -> void:
	if enemy_counter >= enemy_limit:
		spawn_timer.stop()
		spawn_limit_reached = true
	enemy_counter += 1
	var new_enemy = enemy_2.instantiate()
	spawn_pipe_index += 1
	if spawn_pipe_index > 3:
		spawn_pipe_index = 1
	match spawn_pipe_index:
		1: new_enemy.position =  spawn_point_parent.get_child(2).global_position
		2: new_enemy.position = spawn_point_parent.get_child(1).global_position
		3: new_enemy.position = spawn_point_parent.get_child(0).global_position
	env.add_child(new_enemy)
	new_enemy.died.connect(remove_enemy)
	enemy_list.append(new_enemy)

func remove_enemy(enemy_to_remove):
	enemy_list.erase(enemy_to_remove)


	
