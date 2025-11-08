extends Node3D

var locked = false
@onready var light = $light_parent/light
@onready var anim = $anim
var is_open = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !locked and !anim.is_playing() and !is_open:
		anim.play("open")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and !anim.is_playing() and is_open:
		anim.play_backwards("open")
	else:
		await  get_tree().create_timer(5).timeout
		if is_open:
			anim.play_backwards("open")


func _on_anim_animation_finished(anim_name: StringName) -> void:
	is_open = !is_open


##contine here! light needs to change based on state unlocked, moving, locked.
func lock():
	locked = true
