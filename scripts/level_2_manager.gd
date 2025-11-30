extends CanvasLayer

var spawn_point_parent 
@onready var env = $ColorRect/SubViewport/Environment
@onready var enemy_2 = preload("res://scenes/enemy_2.tscn")
@onready var enemy_1 = preload("res://scenes/enemy_1.tscn")

@onready var text_controller = $ColorRect/SubViewport/HUD/text_display_bottom
@onready var round_lbl = $ColorRect/SubViewport/HUD/round_lbl

@onready var spawn_timer = $spawn_timer
var spawn_pipe_index = 0
var spawn_pipe_index_max = 3
var enemy_list = []
var enemy_limit = 15
var spawn_limit_reached = false
var enemy_counter = 0

var endgame_round_counter = 1

##triggers
var warehouse_2_trigger = false
var cafe_trigger = false
var trigger_endgame = false

func _ready() -> void:
	$ColorRect/SubViewport/Environment/Player.died.connect(player_dead)
	$ColorRect/SubViewport/Environment/level_2/door4.opening.connect(door_4_opening)
	await get_tree().create_timer(1).timeout
	text_controller.display_text("I need to find a way out of here...")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if trigger_endgame and spawn_limit_reached and enemy_list.is_empty():
		enemy_counter = 0
		enemy_limit += 5
		print("enemy limit is now ", enemy_limit)
		endgame_round_counter += 1
		round_lbl.text = "Round " + str(endgame_round_counter)
		spawn_limit_reached = false
		spawn_timer.start()
		print("round ", endgame_round_counter	)
	elif cafe_trigger and spawn_limit_reached and enemy_list.is_empty():
		spawn_limit_reached = false
		spawn_timer.stop()
		cafe_finished()
	elif warehouse_2_trigger and spawn_limit_reached and enemy_list.is_empty():
		spawn_limit_reached = false
		spawn_timer.stop()
		warehouse_2_finished()
	
		

func _on_warehouse_2_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		trigger_warehouse_2_fight()


func _on_cafe_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$ColorRect/SubViewport/Environment/level_2/object_parent/cafe/keycard.visible = false
		trigger_cafe_fight()
	
	
	
func trigger_warehouse_2_fight():
	if warehouse_2_trigger:
		return
	$ColorRect/SubViewport/Environment/warehouse2_trigger.set_deferred("monitoring",false)
	warehouse_2_trigger = true
	spawn_point_parent = $ColorRect/SubViewport/Environment/enemy_spawns_wh2
	var door_1 = $ColorRect/SubViewport/Environment/level_2/door12
	door_1.toggle_invisible_wall()
	door_1.lock()
	enemy_counter = 0
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
	enemy_counter = 0
	spawn_limit_reached = false
	enemy_limit = 20
	spawn_timer.wait_time = 1.5
	spawn_timer.start()

func trigger_endgame_fight():
	spawn_point_parent = $ColorRect/SubViewport/Environment/enemy_spawns_endgame
	spawn_limit_reached = false
	enemy_counter = 0
	enemy_limit = 20
	endgame_round_counter = 1
	spawn_pipe_index_max = 11
	spawn_timer.start()

func warehouse_2_finished():
	$ColorRect/SubViewport/Environment/level_2/door11.unlock()
	$ColorRect/SubViewport/Environment/level_2/door12.unlock()
	$ColorRect/SubViewport/Environment/level_2/door12.toggle_invisible_wall()
	$ColorRect/SubViewport/Environment/level_2/door2.unlock()
	enemy_list.clear()
	await get_tree().create_timer(2).timeout
	text_controller.display_text("I need to find the exit")

func cafe_finished():
	$ColorRect/SubViewport/Environment/level_2/door10.toggle_invisible_wall()
	$ColorRect/SubViewport/Environment/level_2/door10.unlock()
	$ColorRect/SubViewport/Environment/level_2/door4.unlock()
	$ColorRect/SubViewport/Environment/dialogue_door_trigger.monitoring = false

	await get_tree().create_timer(1).timeout
	text_controller.display_text("Time to get out of here!")


func _on_spawn_timer_timeout() -> void:
	if enemy_counter >= enemy_limit:
		spawn_timer.stop()
		spawn_limit_reached = true
	enemy_counter += 1
	var new_enemy = enemy_2.instantiate()
	spawn_pipe_index += 1
	if spawn_pipe_index > spawn_pipe_index_max -1:
		spawn_pipe_index = 0
	new_enemy.position =  spawn_point_parent.get_child(spawn_pipe_index).global_position
	env.add_child(new_enemy)
	new_enemy.died.connect(remove_enemy)
	enemy_list.append(new_enemy)

func remove_enemy(enemy_to_remove):
	enemy_list.erase(enemy_to_remove)
	print(enemy_list.size())


func door_4_opening():
	if trigger_endgame:
		return
	trigger_endgame = true
	
	$ColorRect/SubViewport/Environment/level_2/door4.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door.lock()
	$ColorRect/SubViewport/Environment/level_2/door6.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door2.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door5.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door16.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door7.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door8.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door9.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door15.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door3.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door11.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door13.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door12.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door10.toggle_stay_open()
	$ColorRect/SubViewport/Environment/level_2/door10.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(2).timeout
	$ColorRect/SubViewport/Environment/enemy_1.process_mode = Node.PROCESS_MODE_ALWAYS
	text_controller.display_text("Come and get some!")
	trigger_endgame_fight()
	await get_tree().create_timer(10).timeout
	text_controller.display_text("You will never take me alive!")
	var new_tween = get_tree().create_tween()
	new_tween.tween_property(round_lbl,"modulate",Color(1,1,1,1),1)


func player_dead():
	$ColorRect.fade_to_black(3)
	await get_tree().create_timer(3.5).timeout
	SceneLoader.switch_scene("res://scenes/level_2.tscn")

func _on_dialogue_door_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		text_controller.display_text("I need to find the key.")
