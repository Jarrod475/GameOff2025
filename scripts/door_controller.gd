extends Node3D

var locked = false
@onready var light = $light_parent/light
@onready var anim = $anim
var is_open = false

@export var light_green : Material
@export var light_yellow : Material
@export var light_red : Material

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !locked and !anim.is_playing() and !is_open:
		anim.play("open")
		light.material_override = light_yellow


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and !anim.is_playing() and is_open:
		anim.play_backwards("open")
		light.material_override = light_yellow
	else:
		await  get_tree().create_timer(5).timeout
		if is_open:
			anim.play_backwards("open")
			light.material_override = light_yellow


func _on_anim_animation_finished(anim_name: StringName) -> void:
	is_open = !is_open
	if locked:
		light.material_override = light_red
	else:
		light.material_override = light_green


func lock():
	locked = true
	light.material_override = light_red

func unlock():
	locked = false
	light.material_override = light_green
