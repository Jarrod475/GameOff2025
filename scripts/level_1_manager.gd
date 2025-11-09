extends CanvasLayer

@onready var spawn_point_parent = $ColorRect/SubViewport/Environment/enemy_spawns
@onready var env = $ColorRect/SubViewport/Environment
@onready var enemy = preload("res://scenes/enemy_2.tscn")

func _ready() -> void:
	return
	await get_tree().create_timer(1).timeout
	for n in spawn_point_parent.get_children():
		for d in 5:
			var new_enemy = enemy.instantiate()
			env.add_child(new_enemy)
			new_enemy.position = n.position

##Jarryboi!
##continue here. get this spawner to spawn them 
