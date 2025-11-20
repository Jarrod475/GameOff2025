extends Node3D

@export var locked = false
@onready var light = $light_parent/light
@onready var anim = $anim
@onready var audio = $audio
@onready var invisible_wall_coll = $invisible_wall/CollisionShape3D
var is_open = false

@export var light_green : Material
@export var light_yellow : Material
@export var light_red : Material

signal opening

var locked_in_open_pos = false
func _ready() -> void:
	#toggle_stay_open()
	if locked:
		light.material_override = light_red
	else:
		light.material_override = light_green

		

func _on_area_3d_body_entered(body: Node3D) -> void:
	if locked_in_open_pos:
		return
	if body.is_in_group("player") and !locked and !anim.is_playing() and !is_open:
		opening.emit()
		anim.play("open")
		audio.play()
		light.material_override = light_yellow


func _on_area_3d_body_exited(body: Node3D) -> void:
	if locked_in_open_pos:
		return
	if body.is_in_group("player") and !anim.is_playing() and is_open:
		anim.play_backwards("open")
		audio.play()
		light.material_override = light_yellow
	else:
		await  get_tree().create_timer(5).timeout
		if is_open:
			anim.play_backwards("open")
			audio.play()
			light.material_override = light_yellow


func _on_anim_animation_finished(_anim_name: StringName) -> void:
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

func toggle_invisible_wall():
	invisible_wall_coll.disabled = !invisible_wall_coll.disabled

func toggle_stay_open():
	locked_in_open_pos = !locked_in_open_pos
	if locked_in_open_pos:
		anim.play("open",-1,1,true)
	else:
		anim.play("RESET")
		
